//
//  ContentView.swift
//  Stuby
//
//  Created by apple on 17.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedTab = 0
    @State private var showingAddSubscription = false

    var body: some View {
        ZStack {
            // Main content area - extends to full screen
            ZStack {
                switch selectedTab {
                case 0:
                    DashboardView(subscriptionManager: subscriptionManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case 1:
                    SubscriptionListView(subscriptionManager: subscriptionManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case 2:
                    AnalyticsView(subscriptionManager: subscriptionManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case 3:
                    SettingsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                default:
                    DashboardView(subscriptionManager: subscriptionManager)
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedTab)
            .ignoresSafeArea(.all) // Extend to full screen

            // Custom Tab Bar overlay
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
                    .frame(height: 70)
            }
            .zIndex(1)

            // Center Add Button overlay - brought to front
            VStack {
                Spacer()
                CenterAddButton {
                    showingAddSubscription = true
                }
                .offset(y: -47.5) // Position so bottom half overlaps tab bar
            }
            .zIndex(2) // Highest priority
        }
        .fullScreenCover(isPresented: $showingAddSubscription) {
            AddEditSubscriptionView(subscriptionManager: subscriptionManager)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
