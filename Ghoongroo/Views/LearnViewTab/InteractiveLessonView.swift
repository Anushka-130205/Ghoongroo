import SwiftUI

// MARK: - Interactive Lesson View
// Full-screen interactive module for learning Kathak elements with animated guides

struct InteractiveLessonView: View {
    let element: KathakElement
    var onDismiss: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var isQuizMode = false
    @State private var isCompleted = false
    
    // Quiz state
    @State private var currentQuizQuestion = 0
    @State private var selectedQuizAnswer: Int?
    @State private var showQuizFeedback = false
    @State private var isAnswerCorrect = false
    @State private var quizShakeOffset: CGFloat = 0
    @State private var quizScore = 0
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private var isLandscape: Bool { verticalSizeClass == .compact }
    
    // Auto-generated generic quiz based on element
    private var generatedQuiz: [(question: String, options: [String], correctIndex: Int)] {
        return [
            (
                question: "What is the primary focus when performing \(element.name)?",
                options: ["Maintaining straight posture", "Moving as fast as possible", "Looking down at your feet"],
                correctIndex: 0
            ),
            (
                question: "Which joints require the most precision for this element?",
                options: ["Only the wrists", "The entire body alignment", "Just the ankles"],
                correctIndex: 1
            ),
            (
                question: "How should you approach the rhythm here?",
                options: ["Ignore the beat, focus on grace", "Follow the exact tabla beat", "Clap loudly at random"],
                correctIndex: 1
            )
        ]
    }
    
    var body: some View {
        ZStack {
            KathakTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content Area
                GeometryReader { geo in
                    Group {
                        if isCompleted {
                            completionScreen
                                .transition(.scale.combined(with: .opacity))
                        } else if isQuizMode {
                            quizScreen
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        } else {
                            lessonContent(geo: geo)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Bottom Bar Controls
                if !isCompleted {
                    bottomBar
                }
            }
        }

    }
    
    // MARK: - Lesson Content
    
    private func lessonContent(geo: GeometryProxy) -> some View {
        let step = element.steps[currentStep]
        
        return VStack(spacing: isLandscape ? 12 : 32) {
            Spacer()
            
            // Visual Icon Area
            ZStack {
                Circle()
                    .fill(element.color.opacity(0.06))
                    .frame(width: isLandscape ? 120 : 180, height: isLandscape ? 120 : 180)
                    .blur(radius: 60)
                
                Image(systemName: element.icon)
                    .font(.system(size: isLandscape ? 60 : 90))
                    .foregroundStyle(element.color.opacity(0.6))
            }
            .frame(maxHeight: isLandscape ? .infinity : geo.size.height * 0.4)
            
            // Instructional Text
            VStack(spacing: 16) {
                Text(step.title)
                    .font(isLandscape ? KathakTheme.titleFont : KathakTheme.largeTitleFont)
                    .foregroundStyle(KathakTheme.saffron)
                    .multilineTextAlignment(.center)
                
                Text(step.description)
                    .font(isLandscape ? KathakTheme.subheadlineFont : KathakTheme.headlineFont)
                    .foregroundStyle(KathakTheme.softBeige)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxHeight: isLandscape ? .infinity : geo.size.height * 0.4)
            
            Spacer()
        }
    }
    

    
    // MARK: - Quiz Screen
    
    private var quizScreen: some View {
        let quiz = generatedQuiz[currentQuizQuestion]
        
        return VStack(spacing: 24) {
            Spacer()
            


            Image(systemName: "brain.head.profile")
                .font(KathakTheme.largeTitleFont)
                .foregroundStyle(KathakTheme.warmGold)
            
            Text("Knowledge Check")
                .font(KathakTheme.titleFont)
                .foregroundStyle(KathakTheme.saffron)
            
            Text(quiz.question)
                .font(KathakTheme.calloutFont)
                .foregroundStyle(KathakTheme.softBeige)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 12) {
                ForEach(0..<quiz.options.count, id: \.self) { index in
                    quizOptionButton(index: index, text: quiz.options[index], correctIndex: quiz.correctIndex)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .modifier(ShakeEffect(animatableData: quizShakeOffset))
            
            Spacer()
        }

    }
    
    private func quizOptionButton(index: Int, text: String, correctIndex: Int) -> some View {
        let isSelected = selectedQuizAnswer == index
        let isCorrect = index == correctIndex
        
        var bgColor: Color = Color.white.opacity(0.05)
        var borderColor: Color = KathakTheme.warmGold.opacity(0.15)
        var textColor: Color = KathakTheme.softBeige
        
        if showQuizFeedback {
            if isSelected {
                bgColor = isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
                borderColor = isCorrect ? Color.green : Color.red
                textColor = isCorrect ? Color.green : Color.red
            } else if isCorrect {
                // Show the right answer if they picked wrong
                borderColor = Color.green.opacity(0.5)
                textColor = Color.green.opacity(0.8)
            }
        }
        
        return Button(action: {
            if !showQuizFeedback {
                handleQuizAnswer(index: index, isCorrect: isCorrect)
            }
        }) {
            HStack {
                Text(text)
                    .font(KathakTheme.subheadlineFont)
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.leading)
                Spacer()
                if showQuizFeedback && (isSelected || isCorrect) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(isCorrect ? Color.green : Color.red)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(bgColor)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
            )
        }
        .disabled(showQuizFeedback)
    }
    
    private func handleQuizAnswer(index: Int, isCorrect: Bool) {
        selectedQuizAnswer = index
        self.isAnswerCorrect = isCorrect
        
        if isCorrect {
            quizScore += 1
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            showQuizFeedback = true
        }
        
        #if canImport(UIKit)
        if isCorrect {
            KathakTheme.hapticSuccess()
        } else {
            KathakTheme.hapticHeavy()
        }
        #endif
        
        if !isCorrect {
            withAnimation(.default) {
                quizShakeOffset = 1
            }
            // Auto advance after wrong answer delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                advanceQuiz()
            }
        } else {
            // Auto advance faster for correct answer
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                advanceQuiz()
            }
        }
    }
    
    private func advanceQuiz() {
        withAnimation {
            showQuizFeedback = false
            selectedQuizAnswer = nil
            quizShakeOffset = 0
            
            if currentQuizQuestion < generatedQuiz.count - 1 {
                currentQuizQuestion += 1
            } else {
                isCompleted = true
            }
        }
    }
    
    // MARK: - Completion Screen
    
    private var completionScreen: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(KathakTheme.warmGold.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "star.fill")
                    .font(KathakTheme.largeTitleFont)
                    .foregroundStyle(KathakTheme.brightGold)
            }
            
            Text("Lesson Complete!")
                .font(KathakTheme.largeTitleFont)
                .foregroundStyle(KathakTheme.saffron)
            
            Text("Quiz Score: \(quizScore)/\(generatedQuiz.count)")
                .font(KathakTheme.headlineFont)
                .foregroundStyle(KathakTheme.softBeige)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.clear))
                .background(.ultraThinMaterial, in: Capsule())
            
            Text("You've unlocked the knowledge of \(element.name). Now it's time to put it into practice.")
                .font(KathakTheme.calloutFont)
                .foregroundStyle(KathakTheme.softBeige.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                if let onDismiss = onDismiss {
                    onDismiss()
                } else {
                    dismiss()
                }
            }) {
                Text("Return to Library")
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(KathakTheme.creamWhite)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(KathakTheme.warmGold)
            .controlSize(.large)
            .padding(.top, 24)
        }
    }
    
    // MARK: - Bottom Bar Controls
    
    private var bottomBar: some View {
        HStack {
            // Back Button
            Button(action: {
                #if canImport(UIKit)
                KathakTheme.hapticLight()
                #endif
                withAnimation(.spring) {
                    if isQuizMode {
                        // Prevent going back in quiz
                    } else if currentStep > 0 {
                        currentStep -= 1
                    }
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(KathakTheme.subheadlineFont)
                .foregroundStyle(KathakTheme.softBeige.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .opacity((currentStep == 0 || isQuizMode) ? 0 : 1)
            
            Spacer()
            
            // Next Button
            Button(action: handleNextAction) {
                HStack(spacing: 6) {
                    Text(nextButtonText)
                    Image(systemName: "chevron.right")
                }
                .font(KathakTheme.headlineFont)
                .foregroundStyle(KathakTheme.deepMaroon)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(element.color)
                )
            }
            .opacity(isQuizMode ? 0 : 1)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
    
    private var nextButtonText: String {
        if currentStep == element.steps.count - 1 {
            return "Take Quiz"
        } else {
            return "Next Step"
        }
    }
    
    private func handleNextAction() {
        #if canImport(UIKit)
        KathakTheme.hapticMedium()
        #endif
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if currentStep == element.steps.count - 1 {
                isQuizMode = true
                currentQuizQuestion = 0
                quizScore = 0
            } else {
                currentStep += 1
            }
        }
    }

}

// MARK: - Supporting Views and Mods


// Modern shake effect modifier for wrong answers
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat // driving state
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}
