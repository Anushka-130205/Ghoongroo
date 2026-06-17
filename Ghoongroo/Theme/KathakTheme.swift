import SwiftUI

// MARK: - Ghoongroo Design System
// Elegant Indian aesthetic: beige, maroon, gold, deep brown
// Accent Colors: warmGold (primary), saffron (secondary/orange)

struct KathakTheme {

    // MARK: Colors
    static let deepMaroon   = Color(red: 0.45, green: 0.08, blue: 0.12)
    static let richMaroon   = Color(red: 0.55, green: 0.10, blue: 0.15)
    static let warmGold     = Color(red: 0.85, green: 0.68, blue: 0.32)
    static let brightGold   = Color(red: 0.93, green: 0.79, blue: 0.38)
    static let softBeige    = Color(red: 0.96, green: 0.93, blue: 0.87)
    static let creamWhite   = Color(red: 0.99, green: 0.97, blue: 0.94)
    static let deepBrown    = Color(red: 0.25, green: 0.15, blue: 0.10)
    static let charcoal     = Color(red: 0.18, green: 0.13, blue: 0.11)
    static let terracotta   = Color(red: 0.76, green: 0.38, blue: 0.22)
    static let saffron      = Color(red: 0.95, green: 0.55, blue: 0.15)

    // MARK: Gradients
    static let maroonGradient = LinearGradient(
        colors: [deepMaroon, richMaroon, deepMaroon.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldShimmer = LinearGradient(
        colors: [warmGold, brightGold, warmGold],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [charcoal, deepBrown, Color(red: 0.22, green: 0.12, blue: 0.10)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.08),
            Color.white.opacity(0.03)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let scoreFillGradient = AngularGradient(
        colors: [warmGold, saffron, terracotta, warmGold],
        center: .center
    )

    // MARK: Shadows
    static let goldGlow: Color = warmGold.opacity(0.4)

    // MARK: Semantic Typography (Dynamic Type)
    // Maps exactly to iOS HIG standard text styles to support accessibility scaling automatically.

    static let largeTitleFont: Font = .system(.largeTitle, design: .default).weight(.bold)
    static let titleFont: Font = .system(.title, design: .default).weight(.bold)
    static let title2Font: Font = .system(.title2, design: .default).weight(.semibold)
    static let title3Font: Font = .system(.title3, design: .default).weight(.semibold)
    
    static let headlineFont: Font = .system(.headline, design: .default).weight(.semibold)
    static let subheadlineFont: Font = .system(.subheadline, design: .default).weight(.regular)
    
    static let bodyFont: Font = .system(.body, design: .default).weight(.regular)
    static let calloutFont: Font = .system(.callout, design: .default).weight(.medium)
    
    static let captionFont: Font = .system(.caption, design: .default).weight(.medium)
    static let caption2Font: Font = .system(.caption2, design: .default).weight(.medium)

    // MARK: Spacing Scale

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: Corner Radius Scale

    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }

    // MARK: Haptics

    #if canImport(UIKit)
    @MainActor static func hapticLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    @MainActor static func hapticMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    @MainActor static func hapticHeavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    @MainActor static func hapticSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    @MainActor static func hapticSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    #endif
}

// MARK: - Decorative Modifiers

struct GlassMorphism: ViewModifier {
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(KathakTheme.warmGold.opacity(0.3), lineWidth: 1)
                    )
            )
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}

struct FloatingCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(KathakTheme.cardGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(KathakTheme.warmGold.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: KathakTheme.saffron.opacity(0.3), radius: 12, y: 4)
            )
    }
}

extension View {
    func glassMorphism(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassMorphism(cornerRadius: cornerRadius))
    }

    func floatingCard() -> some View {
        modifier(FloatingCard())
    }
}

// MARK: - Decorative Elements

struct PaisleyBorder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .strokeBorder(
                KathakTheme.goldShimmer,
                lineWidth: 2
            )
    }
}

struct OrnamentalDivider: View {
    var body: some View {
        HStack(spacing: 8) {
            capsuleLine
            diamond
            capsuleLine
        }
        .frame(height: 20)
    }

    private var capsuleLine: some View {
        KathakTheme.warmGold.opacity(0.5)
            .frame(height: 1)
    }

    private var diamond: some View {
        Image(systemName: "diamond.fill")
            .font(.system(.caption2, design: .default))
            .foregroundStyle(KathakTheme.warmGold)
    }
}

struct PulsingDot: View {
    @State private var isPulsing = false

    var color: Color = KathakTheme.warmGold

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .scaleEffect(isPulsing ? 1.4 : 1.0)
            .opacity(isPulsing ? 0.6 : 1.0)
            .animation(
                .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

// MARK: - Animated Background Particles

struct FloatingParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var speed: Double
}

struct ParticleField: View {
    @State private var particles: [FloatingParticle] = []
    @State private var animationPhase: CGFloat = 0

    let particleCount: Int

    init(count: Int = 15) {
        self.particleCount = count
    }

    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let yOffset = sin(animationPhase * particle.speed + particle.x) * 20
                let point = CGPoint(
                    x: particle.x * size.width,
                    y: (particle.y * size.height) + yOffset
                )
                var pCtx = context
                pCtx.opacity = particle.opacity * 0.6
                pCtx.fill(
                    Circle().path(in: CGRect(
                        x: point.x - particle.size / 2,
                        y: point.y - particle.size / 2,
                        width: particle.size,
                        height: particle.size
                    )),
                    with: .color(KathakTheme.warmGold)
                )
            }
        }
        .onAppear {
            particles = (0..<particleCount).map { _ in
                FloatingParticle(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: 0...1),
                    size: CGFloat.random(in: 2...5),
                    opacity: Double.random(in: 0.2...0.6),
                    speed: Double.random(in: 0.5...2.0)
                )
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                animationPhase = .pi * 2
            }
        }
        .allowsHitTesting(false)
    }
}
