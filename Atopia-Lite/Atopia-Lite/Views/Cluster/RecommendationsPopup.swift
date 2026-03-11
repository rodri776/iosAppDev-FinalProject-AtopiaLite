import SwiftUI

struct RecommendationsPopup: View {
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Recommendations")
                    .font(.system(size: 25, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { onDismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
                .accessibilityLabel("Close")
                .accessibilityHint("Dismisses recommendations info")
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("How Recommendations Work", icon: "lightbulb.fill")
                    
                    Text("When you save datapoints, The Cluster builds a mathematical profile of your interests using Natural Language embeddings. Then, it finds new datapoints that are semantically similar to what you've already saved.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 10) {
                    sectionHeader("How To Use", icon: "hand.tap.fill")
                    
                    tipRow(icon: "sparkles", color: Color("RecPurple1"),
                           text: "Save 4+ datapoints to unlock recommendations")
                    tipRow(icon: "checkmark.circle", color: Color("SavedGreen"),
                           text: "Tap a recommended node to save it to your profile")
                    tipRow(icon: "xmark.circle", color: .red,
                           text: "Click Dismiss to clear recommendations from the graph")
                    tipRow(icon: "arrow.triangle.2.circlepath", color: .blue,
                           text: "Add more datapoints, then re-recommend for fresh suggestions")
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("Under the Hood", icon: "gearshape.2.fill")
                    
                    Text("Recommendations use Apple's NLEmbedding to:")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        hoodStep("1", text: "Convert your saved interests into vectors")
                        hoodStep("2", text: "Compute a centroid of your preferences")
                        hoodStep("3", text: "Find the closest unsaved items by cosine similarity")
                    }
                    .padding(.leading, 4)
                }
            }
        }
        .padding(24)
        .background {
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.clear)
                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("BackgroundColor").opacity(0.9))
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 20)
                    )
            }
        }

    }
    
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.accentColor)
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(.primary)
        }
    }
    
    private func tipRow(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 22)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary.opacity(0.8))
        }
    }
    
    private func hoodStep(_ number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.accentColor.opacity(0.7))
                .frame(width: 16)
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    RecommendationsPopup(onDismiss: {})
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
}
