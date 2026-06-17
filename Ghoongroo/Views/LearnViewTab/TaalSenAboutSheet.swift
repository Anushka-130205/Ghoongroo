import SwiftUI

// MARK: - About App Sheet
// A beautiful native sheet displaying the app's philosophy, features, and credits.

struct TaalSenAboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                KathakTheme.backgroundGradient.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        
                        // MARK: - Header (Icon & App Name)
                        VStack(spacing: 12) {
                            Image("app") // Replaced with actual App Icon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: KathakTheme.warmGold.opacity(0.2), radius: 10, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(KathakTheme.warmGold.opacity(0.3), lineWidth: 1)
                                )
                            
                            VStack(spacing: 4) {
                                Text("Ghoongroo")
                                    .font(KathakTheme.titleFont.weight(.bold))
                                    .foregroundStyle(.white)
                                
                                Text("Version 1.0")
                                    .font(KathakTheme.subheadlineFont)
                                    .foregroundStyle(KathakTheme.softBeige.opacity(0.6))
                            }
                        }
                        .padding(.top, 24)
                        
                        // MARK: - Philosophy
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Our Philosophy")
                                .font(KathakTheme.headlineFont)
                                .foregroundStyle(KathakTheme.saffron)
                                .padding(.horizontal, 8)
                            
                            Text("Kathak is not just a dance; it is a profound storyteller. Ghoongroo was designed to make classical rhythms tangible, allowing you to see, hear, and perfect the ancient art of Kathak using the technology of today.")
                                .font(KathakTheme.bodyFont)
                                .foregroundStyle(KathakTheme.softBeige.opacity(0.9))
                                .lineSpacing(4)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.04))
                                )
                        }
                        
                        // MARK: - Features
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Features")
                                .font(KathakTheme.headlineFont)
                                .foregroundStyle(KathakTheme.saffron)
                                .padding(.horizontal, 8)
                            
                            VStack(spacing: 0) {
                                featureRow(
                                    icon: "cube.transparent",
                                    iconColor: KathakTheme.saffron,
                                    title: "Interactive AI Posture",
                                    description: "Built with Vision framework to render real-time human pose estimation, tracking your joint angles and spinal alignment in 3D space."
                                )
                                
                                Divider().background(Color.white.opacity(0.1)).padding(.leading, 56)
                                
                                featureRow(
                                    icon: "atom",
                                    iconColor: KathakTheme.warmGold,
                                    title: "AI Powered Insights",
                                    description: "Uses a rule-based AI engine to generate strict, immediate feedback on your Kathak stances and rhythmic precision."
                                )
                                
                                Divider().background(Color.white.opacity(0.1)).padding(.leading, 56)
                                
                                featureRow(
                                    icon: "waveform",
                                    iconColor: KathakTheme.terracotta,
                                    title: "Haptic & Audio Synergy",
                                    description: "Integrates CoreHaptics and custom AVFoundation audio pools so you feel and hear the exact moments the rhythm aligns."
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.04))
                            )
                        }
                        
                        // Removed "The Horizon" section as requested
                        
                        // MARK: - Credits
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Credits")
                                .font(KathakTheme.headlineFont)
                                .foregroundStyle(KathakTheme.saffron)
                                .padding(.horizontal, 8)
                            
                            VStack(spacing: 0) {
                                creditRow(title: "Developer", value: "Anushka Sharma")
                                Divider().background(Color.white.opacity(0.1)).padding(.leading, 16)
                                creditRow(title: "Made for", value: "WWDC26 Swift Student Challenge")
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.04))
                            )
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(KathakTheme.charcoal, for: .navigationBar)
        }
    }
    
    // MARK: - Reusable Views
    
    private func featureRow(icon: String, iconColor: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(KathakTheme.title2Font)
                .foregroundStyle(iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(KathakTheme.softBeige)
                
                Text(description)
                    .font(KathakTheme.subheadlineFont)
                    .foregroundStyle(KathakTheme.softBeige.opacity(0.6))
                    .lineSpacing(2)
            }
            Spacer()
        }
        .padding(16)
    }
    
    private func creditRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(KathakTheme.bodyFont)
                .foregroundStyle(KathakTheme.softBeige)
            
            Spacer()
            
            Text(value)
                .font(KathakTheme.bodyFont)
                .foregroundStyle(KathakTheme.softBeige.opacity(0.6))
                .multilineTextAlignment(.trailing)
        }
        .padding(16)
    }
}

