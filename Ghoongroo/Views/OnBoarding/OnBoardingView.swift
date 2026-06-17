import SwiftUI

// MARK: - Onboarding View
// Immersive full-screen welcome experience with cinematic animation

struct OnBoardingView: View {
    
    @State private var showBackground = false
    @State private var showRings = false
    @State private var showSilhouette = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showButton = false
    @State private var isFloating = false
    @State private var ringRotation: Double = 0
    @State private var dismissing = false
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private var isLandscape: Bool { verticalSizeClass == .compact }
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Immersive layered background
            Color.black
                .ignoresSafeArea()
            
            KathakTheme.backgroundGradient
                .ignoresSafeArea()
                .opacity(showBackground ? 1 : 0)
            
            // Rich particle atmosphere
            ParticleField(count: 25)
                .ignoresSafeArea()
                .opacity(showBackground ? 0.5 : 0)
            
            // Radial ambient glow
            RadialGradient(
                colors: [KathakTheme.warmGold.opacity(0.12), .clear],
                center: isLandscape ? .leading : .center,
                startRadius: 40,
                endRadius: 400
            )
            .ignoresSafeArea()
            .opacity(showSilhouette ? 1 : 0)
            
            if isLandscape {
                landscapeLayout
            } else {
                portraitLayout
            }
        }
        .onAppear(perform: animateSequence)
    }
    
    // MARK: - Portrait Layout
    
    private var portraitLayout: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 60)
            
            // Hero with concentric rings
            heroSection
            
            Spacer(minLength: 32)
            
            // Text Content
            VStack(spacing: 12) {
                Text("Ghoongroo")
                    .font(KathakTheme.largeTitleFont)
                    .foregroundStyle(KathakTheme.warmGold)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 16)
                
                Text("Your Kathak Enhancing Companion")
                    .font(KathakTheme.title3Font)
                    .foregroundStyle(KathakTheme.saffron)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 12)
                
                OrnamentalDivider()
                    .frame(width: 100)
                    .opacity(showSubtitle ? 1 : 0)
                    .padding(.vertical, 4)
                
                Text("Practice authentic poses, receive real-time\nfeedback, and master the rhythm of Teentaal.")
                    .font(KathakTheme.subheadlineFont)
                    .foregroundStyle(KathakTheme.softBeige.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 10)
            }
            
            Spacer(minLength: 40)
            
            // CTA Button
            ctaButton
                .padding(.horizontal, 48)
                .padding(.bottom, 56)
        }
    }
    
    // MARK: - Landscape Layout
    
    private var landscapeLayout: some View {
        HStack(spacing: 24) {
            heroSection
                .frame(maxWidth: .infinity)
                .padding(.leading, 32)
            
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ghoongroo")
                        .font(KathakTheme.largeTitleFont)
                        .foregroundStyle(KathakTheme.warmGold)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 12)
                    
                    Text("Your AI-Powered Kathak Mirror")
                        .font(KathakTheme.title3Font)
                        .foregroundStyle(KathakTheme.saffron)
                        .opacity(showSubtitle ? 1 : 0)
                        .offset(y: showSubtitle ? 0 : 10)
                    
                    OrnamentalDivider()
                        .frame(width: 80)
                        .opacity(showSubtitle ? 1 : 0)
                        .padding(.vertical, 2)
                    
                    Text("Practice authentic poses, receive real-time feedback, and master the rhythm of Teentaal.")
                        .font(KathakTheme.subheadlineFont)
                        .foregroundStyle(KathakTheme.softBeige.opacity(0.5))
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 32)
                        .opacity(showSubtitle ? 1 : 0)
                        .offset(y: showSubtitle ? 0 : 10)
                }
                
                ctaButton
                    .frame(maxWidth: 280)
                    .padding(.top, 8)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, 32)
        }
    }
    
    // MARK: - Hero Section (Concentric Gold Rings + Image)
    
    private var heroSection: some View {
        let imageSize: CGFloat = isLandscape ? 160 : 200
        
        return ZStack {
            // Outer decorative ring — slow rotation
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [
                            KathakTheme.warmGold.opacity(0.4),
                            KathakTheme.warmGold.opacity(0.05),
                            KathakTheme.warmGold.opacity(0.3),
                            KathakTheme.warmGold.opacity(0.05),
                            KathakTheme.warmGold.opacity(0.4)
                        ],
                        center: .center
                    ),
                    lineWidth: 1
                )
                .frame(width: imageSize + 60, height: imageSize + 60)
                .rotationEffect(.degrees(ringRotation))
                .opacity(showRings ? 1 : 0)
                .scaleEffect(showRings ? 1 : 0.6)
            
            // Middle ring — dashed, counter-rotation
            Circle()
                .strokeBorder(
                    KathakTheme.warmGold.opacity(0.15),
                    style: StrokeStyle(lineWidth: 0.8, dash: [4, 6])
                )
                .frame(width: imageSize + 36, height: imageSize + 36)
                .rotationEffect(.degrees(-ringRotation * 0.6))
                .opacity(showRings ? 1 : 0)
                .scaleEffect(showRings ? 1 : 0.7)
            
            // Warm glow behind image
            Circle()
                .fill(
                    RadialGradient(
                        colors: [KathakTheme.warmGold.opacity(0.15), .clear],
                        center: .center,
                        startRadius: imageSize * 0.2,
                        endRadius: imageSize * 0.7
                    )
                )
                .frame(width: imageSize + 40, height: imageSize + 40)
                .opacity(showSilhouette ? 1 : 0)
            
            // Inner border ring
            Circle()
                .strokeBorder(KathakTheme.warmGold.opacity(0.3), lineWidth: 1.5)
                .frame(width: imageSize + 8, height: imageSize + 8)
                .opacity(showRings ? 1 : 0)
                .scaleEffect(showRings ? 1 : 0.8)
            
            // Main dancer image
            Image("KathakDancer")
                .resizable()
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .clipShape(Circle())
                .scaleEffect(isFloating ? 1.015 : 1.0)
                .opacity(showSilhouette ? 1 : 0)
                .scaleEffect(showSilhouette ? 1 : 0.88)
        }
        .frame(width: imageSize + 70, height: imageSize + 70)
    }
    
    // MARK: - CTA Button
    
    private var ctaButton: some View {
        Button(action: {
            #if canImport(UIKit)
            KathakTheme.hapticSuccess()
            #endif
            withAnimation(.easeIn(duration: 0.4)) {
                dismissing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                onComplete()
            }
        }) {
            Text("Let's Feel Kathak")
                .font(KathakTheme.headlineFont)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(KathakTheme.deepMaroon)
            .background(
                Capsule()
                    .fill(KathakTheme.goldShimmer)
                    .shadow(color: KathakTheme.saffron.opacity(0.35), radius: 12, y: 4)
            )
        }
        .opacity(showButton ? (dismissing ? 0 : 1) : 0)
        .offset(y: showButton ? 0 : 24)
    }

    // MARK: - Animations
    
    private func animateSequence() {
        // Background fade-in
        withAnimation(.easeOut(duration: 1.0)) {
            showBackground = true
        }
        
        // Rings appear
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
            showRings = true
        }
        
        // Ring rotation — continuous, slow
        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
        
        // Image reveal
        withAnimation(.easeOut(duration: 0.9).delay(0.5)) {
            showSilhouette = true
        }
        
        // Gentle float
        withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true).delay(1.0)) {
            isFloating = true
        }
        
        // Title
        withAnimation(.easeOut(duration: 0.7).delay(1.0)) {
            showTitle = true
        }
        
        // Subtitle + divider
        withAnimation(.easeOut(duration: 0.7).delay(1.4)) {
            showSubtitle = true
        }
        
        // Button
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(1.9)) {
            showButton = true
        }
    }
}
