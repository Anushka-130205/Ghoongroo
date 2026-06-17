import SwiftUI

// MARK: - Timeline Annotation View
// A UI component that overlays practice insights onto a video timeline
// with interactive tap-to-reveal tooltips for each Red/Green marker

struct TimelineAnnotationView: View {
    let duration: Double // Total duration of the practice session
    let annotations: [VideoAnnotation]
    @Binding var currentTime: Double
    var onAnnotationTapped: ((VideoAnnotation) -> Void)?
    
    @State private var highlightedAnnotation: VideoAnnotation?
    @State private var tooltipTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 8)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                // Progress Fill
                Rectangle()
                    .fill(KathakTheme.warmGold.opacity(0.6))
                    .frame(width: max(0, min(geometry.size.width, geometry.size.width * (currentTime / max(duration, 1)))), height: 8)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                // Annotation Markers (Red/Green dots)
                ForEach(annotations) { annotation in
                    let position = max(0, min(geometry.size.width, geometry.size.width * (annotation.time / max(duration, 1))))
                    let isPositive = annotation.insight.type.isPositive
                    let dotColor: Color = isPositive ? .green : .red
                    
                    ZStack {
                        // Dot
                        Circle()
                            .fill(dotColor)
                            .frame(width: highlightedAnnotation?.id == annotation.id ? 18 : 14,
                                   height: highlightedAnnotation?.id == annotation.id ? 18 : 14)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(color: dotColor.opacity(0.5), radius: highlightedAnnotation?.id == annotation.id ? 6 : 2)
                            .animation(.spring(response: 0.3), value: highlightedAnnotation?.id)
                        
                        // Tooltip (appears on tap)
                        if highlightedAnnotation?.id == annotation.id {
                            tooltipView(for: annotation, isPositive: isPositive)
                                .offset(y: -50)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .position(x: position, y: geometry.size.height / 2)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if highlightedAnnotation?.id == annotation.id {
                                highlightedAnnotation = nil
                            } else {
                                highlightedAnnotation = annotation
                                onAnnotationTapped?(annotation)
                                
                                // Auto-dismiss after 3 seconds
                                tooltipTimer?.invalidate()
                                tooltipTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                                    Task { @MainActor in
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            highlightedAnnotation = nil
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // Scrubber Interaction
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let newTime = (value.location.x / geometry.size.width) * duration
                        currentTime = max(0, min(duration, newTime))
                        
                        // Find nearest annotation while scrubbing
                        let nearest = annotations.min(by: {
                            abs($0.time - currentTime) < abs($1.time - currentTime)
                        })
                        if let nearest, abs(nearest.time - currentTime) < (duration * 0.03) {
                            withAnimation(.spring(response: 0.2)) {
                                highlightedAnnotation = nearest
                            }
                        } else {
                            withAnimation(.easeOut(duration: 0.15)) {
                                highlightedAnnotation = nil
                            }
                        }
                    }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeOut) {
                                highlightedAnnotation = nil
                            }
                        }
                    }
            )
        }
        .frame(height: 50) // Extra height for tooltip clearance
    }
    
    // MARK: - Tooltip View
    
    private func tooltipView(for annotation: VideoAnnotation, isPositive: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: annotation.insight.type.icon)
                .font(KathakTheme.captionFont)
                .foregroundStyle(isPositive ? .green : .red)
            
            Text(annotation.insight.type.title)
                .font(KathakTheme.caption2Font)
                .foregroundStyle(.white)
            
            Text(formatTime(annotation.time))
                .font(KathakTheme.caption2Font)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
        )
        .fixedSize()
    }
    
    // MARK: - Helpers
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
struct TimelineAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleInsights = [
            VideoAnnotation(time: 2.5, insight: PracticeInsight(timeRange: 2...4, type: .postureInstability, message: "Sway detected.")),
            VideoAnnotation(time: 8.0, insight: PracticeInsight(timeRange: 7...9, type: .perfectSam, message: "Perfect Sam!")),
            VideoAnnotation(time: 14.2, insight: PracticeInsight(timeRange: 13...16, type: .rushingArms, message: "Rushing arms."))
        ]
        
        TimelineAnnotationView(
            duration: 20.0,
            annotations: sampleInsights,
            currentTime: .constant(5.0)
        ) { annotation in
            print("Tapped: \(annotation.insight.message)")
        }
        .padding()
        .preferredColorScheme(.dark)
    }
}
