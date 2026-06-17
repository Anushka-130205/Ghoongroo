import SwiftUI

// MARK: - Dancer Illustration View
// Maps a visualKey from DiscoverStep to the corresponding 2D dancer illustration.
// Falls back to a themed SF Symbol placeholder when the image isn't available yet.

struct DancerIllustration: View {
    let visualKey: String
    var accentColor: Color = KathakTheme.warmGold

    private var loadedImage: UIImage? {
        // Try loading from bundle as a loose PNG resource
        if let path = Bundle.main.path(forResource: visualKey, ofType: "png"),
           let img = UIImage(contentsOfFile: path) {
            return img
        }
        // Also try asset catalog as fallback
        if let img = UIImage(named: visualKey) {
            return img
        }
        return nil
    }

    var body: some View {
        if let img = loadedImage {
            Image(uiImage: img)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
            // Placeholder for keys without generated images yet
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(accentColor.opacity(0.06))
                
                Image(systemName: "figure.dance")
                    .font(KathakTheme.largeTitleFont)
                    .foregroundStyle(accentColor.opacity(0.35))
            }
        }
    }
}
