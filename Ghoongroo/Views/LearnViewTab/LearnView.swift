import SwiftUI
import SwiftData

// MARK: - Learn View (New Home)
// Primary landing for the Ghoongroo SSC submission — Discover Kathak modules

struct LearnView: View {

    @State private var animateCards = false
    @State private var animateWeekly = false
    @StateObject private var statsManager = DashboardStatsManager()

    @State private var selectedModule: DiscoverModule?
    @State private var showLesson = false
    @State private var showAboutSheet = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var isCompactHeight: Bool { verticalSizeClass == .compact }
    private var isWide: Bool { horizontalSizeClass == .regular || verticalSizeClass == .compact }

    var onBack: (() -> Void)? = nil

    private let modules = DiscoverModule.allModules

    // MARK: - Body

    var body: some View {
        NavigationStack {

            VStack(spacing: 0) {

            ScrollView(showsIndicators: false) {
                VStack(spacing: isCompactHeight ? 12 : 24) {

                    // Dashboard Stats
                    dashboardSection(compact: isCompactHeight)
                        .padding(.top, 16)

                    // Discover Kathak Section Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Discover Kathak")
                            .font(KathakTheme.titleFont)
                            .foregroundStyle(KathakTheme.softBeige)

                        Text("Explore the art, tradition, and technique behind every movement.")
                            .font(KathakTheme.caption2Font)
                            .foregroundStyle(KathakTheme.softBeige.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    // Module Cards
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 300), spacing: 16)],
                        spacing: 16
                    ) {
                        ForEach(Array(modules.enumerated()), id: \.element.id) { index, module in
                            Button {
                                #if canImport(UIKit)
                                KathakTheme.hapticSelection()
                                #endif
                                selectedModule = module
                                showLesson = true
                            } label: {
                                moduleCard(module, index: index)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)

                } // Content VStack
                .padding(.bottom, isCompactHeight ? 16 : 40)
            } // ScrollView
            .navigationTitle("Learn")
            } // Main VStack
            .toolbar {
                Button {
                    showAboutSheet = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.clear, for: .navigationBar)
            .background(
                KathakTheme.backgroundGradient
                    .ignoresSafeArea()
                    .overlay(
                        ParticleField(count: 8)
                            .opacity(0.2)
                            .allowsHitTesting(false)
                            .ignoresSafeArea()
                    )
            )
            .navigationDestination(isPresented: $showLesson) {
                if let module = selectedModule,
                   let topic = module.topics.first {
                    TopicLessonView(topic: topic, moduleTitle: module.title)
                }
            }
            .sheet(isPresented: $showAboutSheet) {
                TaalSenAboutSheet()
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    animateCards = true
                }
                withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                    animateWeekly = true
                }
            }
        } // NavigationStack
    }

    // MARK: - Module Card

    private func moduleCard(_ module: DiscoverModule, index: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(module.accentColor.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: module.icon)
                    .font(KathakTheme.titleFont)
                    .foregroundStyle(KathakTheme.brightGold)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(module.title)
                    .font(KathakTheme.title3Font)
                    .foregroundStyle(KathakTheme.softBeige)

                Text(module.subtitle)
                    .font(KathakTheme.caption2Font)
                    .foregroundStyle(KathakTheme.softBeige.opacity(0.5))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(KathakTheme.subheadlineFont)
                .foregroundStyle(module.accentColor.opacity(0.4))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(module.accentColor.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(module.accentColor.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 4)
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .opacity(animateCards ? 1 : 0)
        .offset(y: animateCards ? 0 : 25)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateCards)
    }

    // MARK: - Weekly Progress Section

    private var weeklyProgressSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .foregroundStyle(KathakTheme.warmGold)
                    .font(KathakTheme.subheadlineFont)
                Text("This Week")
                    .font(KathakTheme.headlineFont)
                    .foregroundStyle(KathakTheme.softBeige)
                Spacer()
                Text("\(statsManager.streakCount)-day streak")
                    .font(KathakTheme.captionFont)
                    .foregroundStyle(KathakTheme.warmGold.opacity(0.7))
            }

            HStack(spacing: 0) {
                let statuses = statsManager.weeklyPracticeStatus
                let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 6) {
                        Text(dayLabels[index])
                            .font(KathakTheme.captionFont)
                            .foregroundStyle(KathakTheme.softBeige.opacity(0.5))

                        weeklyDayCircle(status: statuses[index])
                    }
                    .frame(maxWidth: .infinity)
                    .opacity(animateWeekly ? 1 : 0)
                    .scaleEffect(animateWeekly ? 1 : 0.7)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.06),
                        value: animateWeekly
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(KathakTheme.warmGold.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(KathakTheme.warmGold.opacity(0.12), lineWidth: 1))
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func weeklyDayCircle(status: DashboardStatsManager.DayStatus) -> some View {
        ZStack {
            switch status {
            case .completed:
                Circle()
                    .fill(KathakTheme.warmGold.opacity(0.2))
                    .frame(width: 32, height: 32)
                Circle()
                    .fill(KathakTheme.warmGold)
                    .frame(width: 28, height: 28)
                Image(systemName: "checkmark")
                    .font(KathakTheme.captionFont)
                    .foregroundStyle(KathakTheme.creamWhite)

            case .today:
                Circle()
                    .stroke(KathakTheme.warmGold.opacity(0.3), lineWidth: 2)
                    .frame(width: 32, height: 32)
                Circle()
                    .trim(from: 0, to: 0.65)
                    .stroke(KathakTheme.warmGold, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))
                Circle()
                    .fill(KathakTheme.warmGold.opacity(0.08))
                    .frame(width: 28, height: 28)

            case .missed:
                Circle()
                    .fill(KathakTheme.softBeige.opacity(0.06))
                    .frame(width: 32, height: 32)
                Circle()
                    .stroke(KathakTheme.softBeige.opacity(0.15), lineWidth: 1)
                    .frame(width: 32, height: 32)

            case .future:
                Circle()
                    .fill(KathakTheme.softBeige.opacity(0.03))
                    .frame(width: 32, height: 32)
                Circle()
                    .stroke(KathakTheme.softBeige.opacity(0.08), lineWidth: 1)
                    .frame(width: 32, height: 32)
            }
        }
    }

    // MARK: - Dashboard Section

    private func dashboardSection(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Progress")
                    .font(KathakTheme.titleFont)
                    .foregroundStyle(KathakTheme.softBeige)
                
                Text("Track your daily journey")
                    .font(KathakTheme.caption2Font)
                    .foregroundStyle(KathakTheme.softBeige.opacity(0.5))
            }
            .padding(.horizontal, 8)

            // This Week streak card
            weeklyProgressSection

            // Today's Stats Row (top)
            HStack(spacing: 12) {
                dashboardCard(
                    icon: "figure.dance",
                    value: "\(statsManager.todaySessionCount)",
                    label: "Today's Sessions",
                    color: KathakTheme.saffron,
                    compact: compact
                )

                dashboardCard(
                    icon: "trophy.fill",
                    value: statsManager.todayBestScore > 0 ? "\(Int(statsManager.todayBestScore))" : "—",
                    label: "Today's Best",
                    color: KathakTheme.brightGold,
                    compact: compact
                )
            }

            // Cumulative Stats Row (bottom)
            HStack(spacing: 12) {
                dashboardCard(
                    icon: "clock.fill",
                    value: statsManager.totalPracticeTimeFormatted,
                    label: "Total Time",
                    color: KathakTheme.terracotta,
                    compact: compact
                )

                dashboardCard(
                    icon: "flame.fill",
                    value: "\(statsManager.streakCount)",
                    label: "Day Streak",
                    color: KathakTheme.warmGold,
                    compact: compact
                )
            }


        }
        .padding(.horizontal, 20)
        .onAppear {
            statsManager.refreshDailyStats()
        }
    }


    // MARK: - Helpers

    private func dashboardCard(icon: String, value: String, label: String, color: Color, compact: Bool) -> some View {
        VStack(spacing: compact ? 6 : 8) {
            Image(systemName: icon)
                .font(compact ? KathakTheme.calloutFont : KathakTheme.title3Font)
                .foregroundStyle(color)

            Text(value)
                .font(KathakTheme.title2Font)
                .foregroundStyle(KathakTheme.softBeige)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(KathakTheme.caption2Font)
                .foregroundStyle(KathakTheme.softBeige.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, compact ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: KathakTheme.CornerRadius.lg)
                .fill(color.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: KathakTheme.CornerRadius.lg).stroke(color.opacity(0.2), lineWidth: 1))
                .shadow(color: color.opacity(0.1), radius: 8, y: 2)
        )
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: KathakTheme.CornerRadius.lg))
    }
}

