//
//  ContentView.swift
//  Ghoongroo
//
//  Created by Kartik Kaushik on 20/02/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showingOnboarding: Bool = true
    
    init() {
        #if canImport(UIKit)
        // Translucent frosted-glass / liquid crystal tab bar
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // Deep translucent background with blur
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        appearance.backgroundColor = UIColor(red: 0.18, green: 0.13, blue: 0.11, alpha: 0.75)
        
        // Subtle top separator
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.06)
        
        // Inactive tab icons: muted
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.4)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.4)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        
        // Active tab icons: bright gold
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0.95, green: 0.82, blue: 0.45, alpha: 1.0)
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.95, green: 0.82, blue: 0.45, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        #endif
    }
    
    var body: some View {
        TabView {
            LearnView {
                showingOnboarding = false
            }
            .tabItem {
                Label("Learn", systemImage: "book.fill")
            }

            PracticeEntryView(
                onBack: { showingOnboarding = false }
            )
            .tabItem {
                Label("Practice", systemImage: "video.circle.fill")
            }
        }
        .tint(Color(red: 0.95, green: 0.82, blue: 0.45)) // Gold tint for selected tab
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnBoardingView(onComplete: {
                showingOnboarding = false
            })
        }
    }
}

#if os(iOS)
#Preview {
    ContentView()
}
#endif
