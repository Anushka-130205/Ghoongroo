import SwiftUI

struct PracticeCameraLayer: View {
    let frame: CGImage?

    var body: some View {
        if let frame {
            Image(decorative: frame, scale: 1)
                .resizable()
        } else {
            ZStack {
                KathakTheme.charcoal.ignoresSafeArea()
                VStack {
                    Image(systemName: "video.slash")
                        .font(KathakTheme.largeTitleFont)
                    Text("Lightweight Camera Placeholder")
                        .font(KathakTheme.headlineFont)
                }
                .foregroundStyle(KathakTheme.softBeige.opacity(0.5))
            }
        }
    }
}
