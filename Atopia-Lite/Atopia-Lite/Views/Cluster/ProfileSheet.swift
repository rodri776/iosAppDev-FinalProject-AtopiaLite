import SwiftUI

struct ProfilePopup: View {
    var onDismiss: () -> Void
    var viewModel: GraphViewModel?
    @StateObject private var fallbackViewModel = GraphViewModel()
    
    private var activeViewModel: GraphViewModel {
        viewModel ?? fallbackViewModel
    }
    
    private var savedCategories: [SavedCategory] {
        activeViewModel.getSavedDatapointsByCategory()
    }
    
    // All datapoints with their categories
    private var allDatapoints: [(datapoint: SavedDatapoint, category: SavedCategory)] {
        var result: [(SavedDatapoint, SavedCategory)] = []
        
        for category in savedCategories {
            for datapoint in category.datapoints {
                result.append((datapoint, category))
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header with close button
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "circle.hexagongrid")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Color("SavedGreen"))
                    
                    Text("Your Datapoints")
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: { onDismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
                .accessibilityLabel("Close")
                .accessibilityHint("Dismisses your profile")
            }
            
            if activeViewModel.savedDatapointsCount == 0 {
                emptyStateView
                    .padding(.vertical, 40)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Datapoint chips
                        datapointChipsSection
                        
                        // Category reference key
                        categoryReferenceKey
                    }
                }
                .frame(maxHeight: 400)
            }
        }
        .padding(24)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.clear)
                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
            } else {
                // Fallback for older iOS versions
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("BackgroundColor").opacity(0.9))
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 20)
                    )
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var datapointChipsSection: some View {
        FlowLayout(spacing: 10) {
            ForEach(allDatapoints, id: \.datapoint.id) { item in
                DatapointChip(
                    datapoint: item.datapoint,
                    category: item.category
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var categoryReferenceKey: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CATEGORIES")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
                .tracking(1)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(savedCategories) { category in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(category.color)
                            .frame(width: 10, height: 10)
                        
                        Text(category.name.uppercased())
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("BackgroundColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 72, weight: .light))
                .foregroundColor(.secondary)
            
            Text("No Datapoints Yet")
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundColor(.primary)
            
            Text("Start exploring the graph to save datapoints that describe you")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Datapoint Chip

struct DatapointChip: View {
    let datapoint: SavedDatapoint
    let category: SavedCategory
    
    // Format the category label to show after the datapoint name
    private var categoryLabel: String {
        if let subSub = datapoint.subSubcategory {
            return subSub.uppercased()
        } else {
            return datapoint.subcategory.uppercased()
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Main label
            Text(datapoint.label.uppercased())
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            // Category label
            Text(categoryLabel)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(category.color.opacity(0.25))
                .overlay(
                    Capsule()
                        .stroke(category.color.opacity(0.5), lineWidth: 1.5)
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(datapoint.label), \(category.name) \(categoryLabel)")
    }
}

#Preview {
    ProfilePopup(onDismiss: {})
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
}
