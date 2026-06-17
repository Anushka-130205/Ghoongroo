import SwiftUI

// MARK: - Level Detail View
// The Lesson Library showing specific elements for a chosen difficulty level

struct LevelDetailView: View {
    let difficulty: KathakElement.Difficulty
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedElement: KathakElement?
    @State private var showLesson = false
    @State private var animateCards = false
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isCompactHeight: Bool { verticalSizeClass == .compact }
    
    private var elements: [KathakElement] {
        KathakElement.elements(for: difficulty)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Removed Library title

                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 320), spacing: 16)],
                        spacing: 16
                    ) {
                        ForEach(Array(elements.enumerated()), id: \.element.id) { index, element in
                            lessonCard(element, index: index)
                                .onTapGesture {
                                    #if canImport(UIKit)
                                    KathakTheme.hapticLight()
                                    #endif
                                    selectedElement = element
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        showLesson = true
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    if elements.isEmpty {
                        emptyState
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .background(
            KathakTheme.backgroundGradient
                .ignoresSafeArea()
        )
        .navigationTitle("\(difficulty.rawValue) Library")
        .navigationBarBackButtonHidden(false)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .navigationDestination(isPresented: $showLesson) {
            if let element = selectedElement {
                InteractiveLessonView(element: element)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateCards = true
            }
        }
    }
    
    // MARK: - Lesson Card
    
    private func lessonCard(_ element: KathakElement, index: Int) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(element.color.opacity(0.15))
                    .frame(width: 54, height: 54)
                
                Image(systemName: element.icon)
                    .font(KathakTheme.titleFont)
                    .foregroundStyle(element.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(element.name)
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(KathakTheme.softBeige)
                
                // Details pill row
                HStack(spacing: 8) {
                    detailPill(icon: "sparkles", text: element.hindiName, color: element.color)
                    detailPill(icon: "list.bullet", text: "\(element.steps.count) Steps", color: element.color)
                }
            }
            
            Spacer(minLength: 8)
            
            // Play Button
            ZStack {
                Circle()
                    .fill(element.color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "play.fill")
                    .font(KathakTheme.subheadlineFont)
                    .foregroundStyle(element.color)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(element.color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(element.color.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 8, y: 4)
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08), value: animateCards)
    }
    
    private func detailPill(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(KathakTheme.captionFont)
            Text(text)
                .font(KathakTheme.caption2Font)
        }
        .foregroundStyle(color.opacity(0.9))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(color.opacity(0.15)))
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(KathakTheme.largeTitleFont)
                .foregroundStyle(KathakTheme.warmGold.opacity(0.5))
            
            Text("Coming Soon")
                .font(KathakTheme.title3Font)
                .foregroundStyle(KathakTheme.softBeige)
            
            Text("More advanced lessons will be unlocked as you progress on your Kathak journey.")
                .font(KathakTheme.subheadlineFont)
                .foregroundStyle(KathakTheme.softBeige.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
