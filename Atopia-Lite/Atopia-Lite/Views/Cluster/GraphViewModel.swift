//
//  GraphViewModel.swift
//  TheCluster
//
//  Created by Juniper Rodriguez on 2/16/26.
//

import SwiftUI
import Combine

@MainActor
class GraphViewModel: ObservableObject {
    @Published var nodes: [Node] = []
    @Published var edges: [Edge] = []
    @Published var groupBackgrounds: [GroupBackground] = []
    @Published var showInstructions = true
    @Published var instructionState: InstructionState = .idle
    @Published var zoomScale: CGFloat = 1.0
    @Published var panOffset: CGSize = .zero
    @Published var activePath: [UUID] = []
    @Published var showMyProfile: Bool = false
    @Published var hasActiveRecommendations: Bool = false
    @Published var isCalculatingRecommendations: Bool = false
    @Published var recommendationError: String?
    
    var instructionText: String { instructionState.text }
    var savedDatapointsCount: Int { profileManager.savedDatapointsCount }
    var canShowRecommendations: Bool { profileManager.canShowRecommendations }
    
    private var graphEngine: GraphEngine!
    private(set) var profileManager: UserProfileManager!
    private var nodeExpansionManager: NodeExpansionManager!
    private(set) var embeddingManager: EmbeddingManager!
    private var recommendationCoordinator: RecommendationCoordinator!
    private var recommendationDisplayManager: RecommendationDisplayManager!
    private var canvasSize: CGSize = .zero
    private var displayLink: CADisplayLink?
    private var physicsEngine: PhysicsEngine
    private var instructionResetTask: Task<Void, Never>?
    
    private(set) var dataItems: [DataItem] = []
    private var categoryHierarchy: [CategoryNode] = []
    private var nodeMetadata: [UUID: NodeMetadata] = [:]
    
    init(profileManager: UserProfileManager? = nil) {
        print("[Graph] GraphViewModel initializing")
        self.physicsEngine = PhysicsEngine()
        
        loadDataset()
        
        self.graphEngine = GraphEngine(physicsEngine: physicsEngine)
        self.profileManager = profileManager ?? UserProfileManager()
        self.nodeExpansionManager = NodeExpansionManager(
            profileManager: self.profileManager,
            categoryHierarchy: categoryHierarchy
        )
        self.embeddingManager = EmbeddingManager()
        self.recommendationCoordinator = RecommendationCoordinator(embeddingManager: embeddingManager)
        self.recommendationDisplayManager = RecommendationDisplayManager()
        
        embeddingManager.preEmbed(labels: dataItems.map { $0.label })
        
        startPhysics()
        print("[Graph] GraphViewModel ready: \(dataItems.count) items, \(categoryHierarchy.count) categories")
    }
    
    private func loadDataset() {
        let result = DatasetLoader.loadDataset()
        dataItems = result.items
        categoryHierarchy = result.hierarchy
        print("[Graph] Dataset loaded: \(dataItems.count) items, \(categoryHierarchy.count) categories")
    }
    
    func setupInitialNode(in size: CGSize) {
        canvasSize = size
        graphEngine.setCanvasSize(size)
        
        let meNode = Node(
            position: CGPoint(x: size.width / 2, y: size.height / 2),
            label: "Me",
            type: .me
        )
        
        nodes = [meNode]
    }
    
    private func startPhysics() {
        displayLink = CADisplayLink(target: self, selector: #selector(updatePhysics))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updatePhysics() {
        guard !nodes.isEmpty else { return }
        
        graphEngine.updatePhysics(nodes: &nodes)
        groupBackgrounds = graphEngine.calculateGroupBackgrounds(for: nodes)
        
        let (newZoom, newPan) = graphEngine.calculateZoomAndPan(
            for: nodes,
            currentZoom: zoomScale,
            currentPan: panOffset
        )
        zoomScale = newZoom
        panOffset = newPan
    }
    
    func toggleNode(nodeId: UUID) {
        guard let index = nodes.firstIndex(where: { $0.id == nodeId }) else { return }
        let node = nodes[index]
        print("[Graph] Node tapped: '\(node.label)' (type=\(node.type), expanded=\(node.isExpanded))")
        
        if node.type == .datapoint {
            tapDatapoint(nodeId: nodeId)
            return
        }
        
        if nodes[index].isExpanded {
            collapseNode(nodeId: nodeId)
            return
        }
        
        if let parentId = node.parentId {
            let siblings = nodes.filter { $0.parentId == parentId && $0.id != nodeId && $0.isExpanded }
            siblings.forEach { collapseNode(nodeId: $0.id) }
        }
        
        nodes[index].isExpanded = true
        expandNode(node: node)
        activePath = graphEngine.calculateActivePath(nodes: nodes)
    }
    
    func tapDatapoint(nodeId: UUID) {
        guard let index = nodes.firstIndex(where: { $0.id == nodeId }),
              nodes[index].type == .datapoint else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            nodes[index].isSavedToProfile.toggle()
        }
        
        let saved = nodes[index].isSavedToProfile
        print("[Graph] Datapoint '\(nodes[index].label)' \(saved ? "SAVED" : "REMOVED")")
        
        if let metadata = nodeMetadata[nodeId] {
            let path = profileManager.datapointPath(
                category: metadata.category,
                subcategory: metadata.subcategory,
                subSubcategory: metadata.subSubcategory,
                label: nodes[index].label
            )
            print("[Graph] Datapoint path: \(path)")
            
            if nodes[index].isSavedToProfile {
                profileManager.saveDatapoint(path)
                embeddingManager.embedEagerly(nodes[index].label)
            } else {
                profileManager.removeDatapoint(path)
            }
        }
        
        nodeExpansionManager.updateSavedCounts(nodes: &nodes, nodeMetadata: nodeMetadata)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(nodes[index].isSavedToProfile ? .success : .warning)
        
        instructionState = nodes[index].isSavedToProfile ? .datapointAdded : .datapointRemoved
        
        scheduleInstructionReset(to: .selectingDatapoint)
        
        if hasActiveRecommendations {
            generateRecommendations()
        }
    }
    
    private func expandNode(node: Node) {
        print("[Graph] Expanding node: '\(node.label)' (type=\(node.type))")
        guard let result = nodeExpansionManager.expandNode(node, nodes: nodes, nodeMetadata: nodeMetadata) else {
            print("[Graph] No children to expand for '\(node.label)'")
            return
        }
        
        let creationResult = nodeExpansionManager.createChildNodes(
            labels: result.labels,
            type: result.type,
            parentNode: node,
            parentPosition: node.position,
            spawnRadius: result.spawnRadius,
            inheritedColor: result.inheritedColor,
            nodeMetadata: nodeMetadata
        )
        
        nodes.append(contentsOf: creationResult.nodes)
        edges.append(contentsOf: creationResult.edges)
        for (key, value) in creationResult.metadata {
            nodeMetadata[key] = value
        }
        print("[Graph] Expanded '\(node.label)': added \(creationResult.nodes.count) child nodes, \(creationResult.edges.count) edges")
        
        if let parentIndex = nodes.firstIndex(where: { $0.id == node.id }) {
            nodes[parentIndex].childIds = creationResult.nodes.map { $0.id }
        }
        
        for newNode in creationResult.nodes {
            reparentNodes(newParentNode: newNode)
        }
        
        updateInstructionState(for: result.type)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func collapseNode(nodeId: UUID) {
        print("[Graph] Collapsing node id=\(nodeId)")
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            graphEngine.collapseNode(nodeId: nodeId, nodes: &nodes, edges: &edges)
        }
        
        activePath = graphEngine.calculateActivePath(nodes: nodes)
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        instructionState = .collapseMode
        scheduleInstructionReset(to: .idle)
    }
    
    func generateRecommendations() {
        print("[Graph] Generating recommendations (saved=\(profileManager.savedDatapointsCount))")
        isCalculatingRecommendations = true
        
        Task {
            if !embeddingManager.isReady {
                print("[Graph] Waiting for embedding manager")
                await embeddingManager.waitUntilReady()
            }
            
            let result = recommendationCoordinator.generateRecommendations(
                savedDatapointPaths: profileManager.savedDatapoints,
                allDataItems: dataItems
            )
            
            isCalculatingRecommendations = false
            
            switch result {
            case .success(let recommendations):
                print("[Graph] Recommendations generated: \(recommendations.count) items")
                recommendationError = nil
                showRecommendations(recommendations)
            case .failure(let error):
                print("[Graph] Recommendation error: \(error.localizedDescription)")
                recommendationError = error.localizedDescription
                instructionState = .error(error.localizedDescription)
                scheduleInstructionReset(to: .selectingDatapoint)
                Task {
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    recommendationError = nil
                }
            }
        }
    }
    
    private func showRecommendations(_ recommendations: [ClusterRecommendation]) {
        print("[Graph] Showing \(recommendations.count) recommendations on cluster: \(recommendations.map { $0.label })")
        guard !recommendations.isEmpty else {
            instructionState = .error("No new recommendations found")
            scheduleInstructionReset(to: .selectingDatapoint)
            return
        }
        
        let unsavedRecIds = Set(nodes.filter { $0.isRecommended && !$0.isSavedToProfile }.map { $0.id })
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            nodes.removeAll { unsavedRecIds.contains($0.id) }
            edges.removeAll { unsavedRecIds.contains($0.fromId) || unsavedRecIds.contains($0.toId) }
        }
        
        for i in nodes.indices where nodes[i].isRecommended && nodes[i].isSavedToProfile {
            nodes[i].isRecommended = false
        }
        
        let creationResult = recommendationDisplayManager.createRecommendationNodes(
            recommendations: recommendations,
            nodes: nodes,
            nodeMetadata: nodeMetadata
        )
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            nodes.append(contentsOf: creationResult.nodes)
            edges.append(contentsOf: creationResult.edges)
            for (key, value) in creationResult.metadata {
                nodeMetadata[key] = value
            }
        }
        
        instructionState = .recommendationMode
        hasActiveRecommendations = true
        scheduleInstructionReset(to: .selectingDatapoint)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func dismissRecommendations() {
        print("[Graph] Dismissing recommendations")
        let nodeIdsToRemove = Set(nodes.filter { $0.isFromRecommendation }.map { $0.id })
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            nodes.removeAll { $0.isFromRecommendation }
            edges.removeAll { edge in
                nodeIdsToRemove.contains(edge.fromId) || nodeIdsToRemove.contains(edge.toId)
            }
        }
        
        hasActiveRecommendations = false
        instructionState = .recommendationsDismissed
        scheduleInstructionReset(to: .selectingDatapoint)
        
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    private func reparentNodes(newParentNode: Node) {
        guard let newParentMetadata = nodeMetadata[newParentNode.id] else { return }
        
        for i in 0..<nodes.count {
            guard nodes[i].type == .datapoint,
                  nodes[i].parentId != newParentNode.id,
                  let metadata = nodeMetadata[nodes[i].id] else { continue }
            
            let shouldReparent = graphEngine.shouldReparent(
                node: nodes[i],
                nodeMetadata: metadata,
                newParent: newParentNode,
                newParentMetadata: newParentMetadata,
                nodes: nodes,
                allMetadata: nodeMetadata
            )
            
            if shouldReparent {
                graphEngine.reparentNode(
                    nodeId: nodes[i].id,
                    newParentId: newParentNode.id,
                    nodes: &nodes,
                    edges: &edges,
                    nodeMetadata: nodeMetadata
                )
            }
        }
    }
    
    private func updateInstructionState(for childType: Node.NodeType) {
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            instructionState = childType.instructionState
        }
    }
    
    private func scheduleInstructionReset(to defaultState: InstructionState) {
        instructionResetTask?.cancel()
        
        guard let delay = instructionState.autoResetDelay else { return }
        
        instructionResetTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            instructionState = defaultState
        }
    }
    
    func getSavedDatapointsByCategory() -> [SavedCategory] {
        profileManager.getSavedDatapointsByCategory(allDataItems: dataItems)
    }
    
    func focusState(for node: Node) -> NodeFocusState {
        if activePath.isEmpty {
            return .normal
        }
        
        return activePath.contains(node.id) ? .highlighted : .dimmed
    }
}

private extension Node.NodeType {
    var instructionState: InstructionState {
        switch self {
        case .category: return .exploringCategory
        case .subcategory: return .exploringSubcategory
        case .subSubcategory: return .exploringSubSubcategory
        case .datapoint: return .selectingDatapoint
        case .me: return .idle
        }
    }
}
