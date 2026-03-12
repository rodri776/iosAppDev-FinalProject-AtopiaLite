import SwiftUI

struct OnboardingPopup: View {
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Welcome to The Cluster.")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: { onDismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.accentColor)
                }
                .accessibilityLabel("Close")
                .accessibilityHint("Dismisses welcome screen")
            }
            Divider()
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Text("How it works")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundColor(.primary).opacity(0.5)
                        .textCase(.uppercase)
                    
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.accentColor.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 4)
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "circle.hexagongrid")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("ExpandedGreen"))
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tap nodes to build your interest profile.")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary).opacity(0.75)
                        
                        Text("(The more you add, the better your recommendations)")
                            .font(.system(size: 14, weight: .regular))
                            .italic()
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("SavedGreen"))
                        .frame(width: 24)
                    
                    (Text("Click ") +
                     Text("Recommendations ✨").italic().bold() +
                    Text(" to discover new interests based on what you've already selected."))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary.opacity(0.75))
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                VStack(alignment: .center, spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(.accentColor)
                        .frame(width: 40)
                    
                    VStack(spacing: 8) {
                        Text("Your profile lives on your device, not on a platform.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Instead of every app learning you from scratch, they all draw from one profile you control.")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            Spacer()
                .frame(height: 2)
            
            Button(action: {
                onDismiss()
            }) {
                HStack(spacing: 8) {
                    Text("Start exploring")
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: 225)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color("SavedGreen"))
                )
                .shadow(color: Color("ExpandedGreen").opacity(0.4), radius: 12, x: 0, y: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 16)
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
}

#Preview {
    OnboardingPopup(onDismiss: {})
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
}
