import SwiftUI

struct DashboardView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var theme: ThemeManager
    @State private var isLoading = false
    @State private var showingCalendar = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Welcome Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome back!")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(theme.textPrimaryColor)

                                Text("Here's your subscription overview")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(theme.textSecondaryColor)
                            }

                            Spacer()

                            // Notification Bell
                            Button(action: {
                                showingCalendar = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(theme.cardBackgroundColor)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: theme.shadowColor, radius: 5, x: 0, y: 2)

                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(upcomingNotificationsCount > 0 ? Color.accentOrange : theme.textPrimaryColor)

                                    // Notification badge
                                    if upcomingNotificationsCount > 0 {
                                        Circle()
                                            .fill(Color.error)
                                            .frame(width: 16, height: 16)
                                            .overlay(
                                                Text("\(min(upcomingNotificationsCount, 9))")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                            .offset(x: 12, y: -12)
                                    }
                                }
                            }
                            .animatedButton()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Summary Cards
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            AnimatedSummaryCard(
                                title: "Monthly Total",
                                value: String(format: "$%.2f", subscriptionManager.totalMonthlySpending),
                                icon: "calendar.circle.fill",
                                gradient: Color.primaryGradient
                            )

                            AnimatedSummaryCard(
                                title: "Yearly Total",
                                value: String(format: "$%.2f", subscriptionManager.totalYearlySpending),
                                icon: "chart.line.uptrend.xyaxis.circle.fill",
                                gradient: Color.accentGradient
                            )
                        }

                        HStack(spacing: 16) {
                            AnimatedSummaryCard(
                                title: "Active Subscriptions",
                                value: "\(subscriptionManager.activeSubscriptions.count)",
                                icon: "checkmark.circle.fill",
                                gradient: LinearGradient(colors: [.accentTeal, .accentGreen], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )

                            AnimatedSummaryCard(
                                title: "Due Soon",
                                value: "\(subscriptionManager.upcomingSubscriptions.count)",
                                icon: "clock.circle.fill",
                                gradient: LinearGradient(colors: [.accentOrange, .warning], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    // Overdue Subscriptions
                    if !subscriptionManager.overdueSubscriptions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.error.opacity(0.2))
                                        .frame(width: 32, height: 32)

                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.error)
                                }

                                Text("Overdue Subscriptions")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(theme.textPrimaryColor)

                                Spacer()

                                Text("\(subscriptionManager.overdueSubscriptions.count)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.error)
                                    .cornerRadius(12)
                            }

                            LazyVStack(spacing: 12) {
                                ForEach(subscriptionManager.overdueSubscriptions) { subscription in
                                    AnimatedSubscriptionRow(subscription: subscription)
                                }
                            }
                        }
                        .padding(20)
                        .background(theme.cardBackgroundColor)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.error.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 20)
                    }

                    // Upcoming Renewals
                    if !subscriptionManager.upcomingSubscriptions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.warning.opacity(0.2))
                                        .frame(width: 32, height: 32)

                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.warning)
                                }

                                Text("Upcoming Renewals")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(theme.textPrimaryColor)

                                Spacer()

                                Text("\(subscriptionManager.upcomingSubscriptions.count)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.warning)
                                    .cornerRadius(12)
                            }

                            LazyVStack(spacing: 12) {
                                ForEach(subscriptionManager.upcomingSubscriptions) { subscription in
                                    AnimatedSubscriptionRow(subscription: subscription)
                                }
                            }
                        }
                        .padding(20)
                        .background(theme.cardBackgroundColor)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.warning.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: theme.shadowColor, radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 20)
                    }

                    // Recent Subscriptions
                    if !subscriptionManager.activeSubscriptions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.primaryPurple.opacity(0.2))
                                        .frame(width: 32, height: 32)

                                    Image(systemName: "list.bullet")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.primaryPurple)
                                }

                                Text("Recent Subscriptions")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(theme.textPrimaryColor)

                                Spacer()
                            }

                            LazyVStack(spacing: 12) {
                                ForEach(subscriptionManager.activeSubscriptions.prefix(5)) { subscription in
                                    AnimatedSubscriptionRow(subscription: subscription)
                                }
                            }
                        }
                        .padding(20)
                        .glassMorphismCard()
                        .padding(.horizontal, 20)
                    }

                    // Empty state
                    if subscriptionManager.activeSubscriptions.isEmpty {
                        AnimatedEmptyState(
                            title: "No Subscriptions Yet",
                            subtitle: "Add your first subscription to start tracking your spending and get renewal reminders.",
                            icon: "creditcard.circle",
                            action: nil
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 40)
                    }

                    // Bottom padding for floating action button
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 100)
                }
                .padding(.vertical, 10)
            }
            .background(Color.clear)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingCalendar) {
            NotificationCalendarView(
                subscriptionManager: subscriptionManager,
                isPresented: $showingCalendar
            )
        }
    }

    private var upcomingNotificationsCount: Int {
        let calendar = Calendar.current
        let today = Date()
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today) ?? today

        return subscriptionManager.activeSubscriptions.filter { subscription in
            subscription.nextBillingDate >= today && subscription.nextBillingDate <= nextWeek
        }.count
    }
}

#Preview {
    DashboardView(subscriptionManager: SubscriptionManager())
        .environmentObject(ThemeManager())
}