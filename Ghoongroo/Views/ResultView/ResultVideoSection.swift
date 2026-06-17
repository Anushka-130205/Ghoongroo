import SwiftUI
import AVKit

struct ResultVideoSection: View {

    let videoURL: URL
    let annotations: [VideoAnnotation]
    @Binding var currentTime: Double

    @State private var player: AVPlayer?
    @State private var videoDuration: Double = 0
    @State private var timeObserver: Any?

    var body: some View {
        VStack(spacing: 8) {

            VideoPlayer(player: player)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    Canvas { context, size in
                        let visibleAnnotations = annotations.filter { abs($0.time - currentTime) < 0.6 }
                        
                        for ann in visibleAnnotations {
                            let isPositive = (ann.insight.type == .perfectSam || ann.insight.type == .recovery)
                            // Map positive to a vibrant green/gold, negative to red/terracotta
                            let baseColor = isPositive ? Color.green.opacity(0.8) : Color.red.opacity(0.8)
                            
                            // Position marker at the detected ankle coordinate, fallback to lower-center
                            let center: CGPoint
                            if let loc = ann.insight.location {
                                // Vision coordinates are mapped 0...1 (Top-Left Origin) in PoseDetector
                                center = CGPoint(x: loc.x * size.width, y: loc.y * size.height)
                            } else {
                                center = CGPoint(x: size.width / 2, y: size.height * 0.75)
                            }
                            
                            let timeDiff = abs(ann.time - currentTime)
                            let progress = timeDiff / 0.6
                            
                            let alpha = 1.0 - progress
                            let scale = 1.0 + (progress * 0.8) // Ring expands outwards
                            
                            let rectSize: CGFloat = 50 * scale
                            let rect = CGRect(x: center.x - rectSize/2, y: center.y - rectSize/2, width: rectSize, height: rectSize)
                            
                            let path = Path(ellipseIn: rect)
                            context.stroke(path, with: .color(baseColor.opacity(alpha)), lineWidth: 3)
                            
                            // Draw the icon
                            let text = Text(Image(systemName: ann.insight.type.icon))
                                .font(KathakTheme.title2Font)
                                .foregroundStyle(baseColor.opacity(alpha))
                            context.draw(text, at: center)
                            
                            // Short text label
                            let label = Text(isPositive ? "Perfect" : "Imprecise")
                                .font(KathakTheme.caption2Font)
                                .foregroundStyle(baseColor.opacity(alpha))
                            context.draw(label, at: CGPoint(x: center.x, y: center.y + 40))
                        }
                    }
                    .allowsHitTesting(false)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(KathakTheme.warmGold.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: KathakTheme.saffron.opacity(0.3).opacity(0.3), radius: 10)

            TimelineAnnotationView(
                duration: videoDuration,
                annotations: annotations,
                currentTime: $currentTime
            ) { annotation in
                seek(to: annotation.time)
            }
        }
        .padding(.horizontal)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            cleanup()
        }
    }

    // MARK: - Video Setup

    private func setupPlayer() {
        let newPlayer = AVPlayer(url: videoURL)
        self.player = newPlayer

        Task {
            if let asset = newPlayer.currentItem?.asset {
                let duration = try? await asset.load(.duration)
                await MainActor.run {
                    videoDuration = duration?.seconds ?? 0
                }
            }
        }

        timeObserver = newPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.1, preferredTimescale: 600),
            queue: .main
        ) { [self] time in
            Task { @MainActor [self] in
                currentTime = time.seconds
            }
        }
    }

    private func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
        player?.play()
    }

    private func cleanup() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
    }
}
