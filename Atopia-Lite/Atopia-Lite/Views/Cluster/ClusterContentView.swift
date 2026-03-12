import SwiftUI

struct ClusterContentView: View {
    @StateObject private var viewModel: GraphViewModel
    @State private var showOnboardingPopup = false
    @State private var showProfileSheet = false
    @State private var showRecommendationsPopup = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    let isOnboarding: Bool
    var onOnboardingComplete: (() -> Void)?
    
    init(isOnboarding: Bool = false, profileManager: UserProfileManager? = nil, onOnboardingComplete: (() -> Void)? = nil) {
        self.isOnboarding = isOnboarding
        self.onOnboardingComplete = onOnboardingComplete
        _viewModel = StateObject(wrappedValue: GraphViewModel(profileManager: profileManager))
    }
    
    var body: some View {
        ZStack {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()
                VStack {
                    HStack {
                        Button("About The Cluster", systemImage: "info.circle") {
                            showOnboardingPopup = true
                        }
                        .labelStyle(.iconOnly)
                        .accessibilityHint("Shows app instructions")
                        .padding()
                        Spacer()
                        Text("The Cluster").font(.largeTitle).opacity(0.5)
                        Spacer()
                        if !isOnboarding {
                            Button("My Profile", systemImage: "person.circle.fill") {
                                showProfileSheet = true
                            }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.bordered)
                            .accessibilityHint("Shows your saved datapoints")
                        }
                    }
                    .padding(.horizontal)
                    if #available(iOS 26.0, *) {
                        Text(viewModel.instructionText)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .glassEffect(in: .capsule)
                            .padding(.horizontal)
                    } else {
                        Text(viewModel.instructionText)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                            )
                            .padding(.horizontal)
                    }
                    
                    GraphView(viewModel: viewModel)
                        .padding(.horizontal)
                    
                    HStack {
                        Button("Recommendations Info", systemImage: "info.circle") {
                            showRecommendationsPopup = true
                        }
                        .labelStyle(.iconOnly)
                        .accessibilityHint("Shows how recommendations work")
                        
                        recommendButton
                        
                        if isOnboarding {
                            VStack(spacing: 4) {
                                Button {
                                    onOnboardingComplete?()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Continue")
                                    }
                                    .font(.system(size: 16, weight: .semibold, design: .serif))
                                    .foregroundColor(viewModel.savedDatapointsCount >= 5 ? .white : .gray)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22)
                                            .fill(viewModel.savedDatapointsCount >= 5 ? Color.accentColor : Color(.systemGray4))
                                    )
                                }
                                .disabled(viewModel.savedDatapointsCount < 5)
                                .accessibilityHint(viewModel.savedDatapointsCount < 5 ? "Save \(5 - viewModel.savedDatapointsCount) more datapoints to continue" : "Finishes onboarding")

                                if viewModel.savedDatapointsCount < 5 {
                                    Text("Save \(5 - viewModel.savedDatapointsCount) more datapoint\(5 - viewModel.savedDatapointsCount == 1 ? "" : "s")")
                                        .font(.system(size: 12, weight: .medium, design: .serif))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding()
                }

            }
            
            if showOnboardingPopup {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showOnboardingPopup = false
                    }
                    .accessibilityLabel("Dismiss")
                    .accessibilityAddTraits(.isButton)
                
                OnboardingPopup(onDismiss: {
                    showOnboardingPopup = false
                })
                .padding(.horizontal, 20)
                .accessibilityAddTraits(.isModal)
            }
            
            if showProfileSheet {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showProfileSheet = false
                    }
                    .accessibilityLabel("Dismiss")
                    .accessibilityAddTraits(.isButton)
                
                ProfilePopup(onDismiss: {
                    showProfileSheet = false
                })
                .padding(.horizontal, 20)
                .accessibilityAddTraits(.isModal)
            }
            
            if showRecommendationsPopup {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showRecommendationsPopup = false
                    }
                    .accessibilityLabel("Dismiss")
                    .accessibilityAddTraits(.isButton)
                
                RecommendationsPopup(onDismiss: {
                    showRecommendationsPopup = false
                })
                .padding(.horizontal, 20)
                .accessibilityAddTraits(.isModal)
            }
        }
        .onAppear {
            if !hasSeenOnboarding {
                showOnboardingPopup = true
                hasSeenOnboarding = true
            }
        }
    }
    
    private var recommendButton: some View {
        let isActive = viewModel.hasActiveRecommendations
        let isCalculating = viewModel.isCalculatingRecommendations
        let canShow = viewModel.canShowRecommendations
        let isEnabled = (isActive || canShow) && !isCalculating
        
        var statusText: String? = nil
        if let errorText = viewModel.recommendationError {
            statusText = errorText
        } else if isCalculating {
            statusText = "Calculating embeddings..."
        } else if !canShow && !isActive {
            statusText = "Save 4+ datapoints to unlock"
        }
        
        return VStack(spacing: 4) {
            Button {
                if isActive {
                    viewModel.dismissRecommendations()
                } else {
                    viewModel.generateRecommendations()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isActive ? "xmark.circle.fill" : "sparkles")
                    Text(isActive ? "Dismiss" : "Recommend")
                }
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(isEnabled ? .white : .gray)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            isActive ? Color.red.opacity(0.8) :
                            isEnabled ? Color("RecPurple1") :
                            Color("BackgroundColor")
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            isActive ? Color.red.opacity(0.5) :
                            isEnabled ? Color("RecPurple2").opacity(0.5) :
                            Color.gray.opacity(0.3),
                            lineWidth: 1.5
                        )
                )
            }
            .disabled(!isEnabled)
            .accessibilityLabel(isActive ? "Dismiss recommendations" : "Generate recommendations")
            .accessibilityHint(isEnabled ? (isActive ? "Removes recommended nodes from the graph" : "Finds new datapoints based on your interests") : (statusText ?? ""))
            
            if let statusText {
                Text(statusText)
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundColor(.gray)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isActive)
        .animation(.easeInOut(duration: 0.25), value: isCalculating)
        .animation(.easeInOut(duration: 0.25), value: canShow)
    }
}
