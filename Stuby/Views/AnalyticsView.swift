import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @State private var selectedPeriod: AnalyticsPeriod = .month

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Summary Cards
                    HStack(spacing: 12) {
                        AnalyticsCard(
                            title: "Total \(selectedPeriod.rawValue)",
                            value: String(format: "$%.2f", selectedPeriod == .month ? subscriptionManager.totalMonthlySpending : subscriptionManager.totalYearlySpending),
                            icon: "dollarsign.circle.fill",
                            color: .green
                        )

                        AnalyticsCard(
                            title: "Active",
                            value: "\(subscriptionManager.activeSubscriptions.count)",
                            icon: "checkmark.circle.fill",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)

                    // Spending by Category Chart
                    if !subscriptionManager.activeSubscriptions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Spending by Category")
                                .font(.headline)
                                .padding(.horizontal)

                            // Simple bar chart representation
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(categoryData.sorted { $0.amount > $1.amount }, id: \.category) { item in
                                    HStack {
                                        Text(item.category.rawValue)
                                            .font(.caption)
                                            .frame(width: 80, alignment: .leading)

                                        GeometryReader { geometry in
                                            HStack {
                                                Rectangle()
                                                    .fill(item.category.color)
                                                    .frame(width: min(geometry.size.width * CGFloat(item.amount / (selectedPeriod == .month ? subscriptionManager.totalMonthlySpending : subscriptionManager.totalYearlySpending)), geometry.size.width))
                                                Spacer(minLength: 0)
                                            }
                                        }
                                        .frame(height: 20)

                                        Text(String(format: "$%.0f", item.amount))
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .frame(width: 40, alignment: .trailing)
                                    }
                                }
                            }
                            .frame(height: 300)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        // Category Breakdown List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category Breakdown")
                                .font(.headline)
                                .padding(.horizontal)

                            LazyVStack(spacing: 8) {
                                ForEach(categoryData.sorted { $0.amount > $1.amount }, id: \.category) { item in
                                    CategoryBreakdownRow(
                                        category: item.category,
                                        amount: item.amount,
                                        percentage: item.amount / (selectedPeriod == .month ? subscriptionManager.totalMonthlySpending : subscriptionManager.totalYearlySpending) * 100,
                                        subscriptionCount: subscriptionManager.subscriptions(for: item.category).count
                                    )
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        // Upcoming Renewals Timeline
                        if !subscriptionManager.upcomingSubscriptions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Upcoming Renewals")
                                    .font(.headline)
                                    .padding(.horizontal)

                                VStack(spacing: 8) {
                                    ForEach(subscriptionManager.upcomingSubscriptions) { subscription in
                                        UpcomingRenewalRow(subscription: subscription)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }

                        // Statistics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Statistics")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 8) {
                                StatisticRow(
                                    label: "Average monthly cost",
                                    value: String(format: "$%.2f", subscriptionManager.totalMonthlySpending / Double(max(1, subscriptionManager.activeSubscriptions.count)))
                                )

                                StatisticRow(
                                    label: "Most expensive",
                                    value: mostExpensiveSubscription
                                )

                                StatisticRow(
                                    label: "Cheapest",
                                    value: cheapestSubscription
                                )

                                StatisticRow(
                                    label: "Most common billing cycle",
                                    value: mostCommonBillingCycle
                                )

                                StatisticRow(
                                    label: "Most common category",
                                    value: mostCommonCategory
                                )
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)

                            Text("No data available")
                                .font(.title2)
                                .fontWeight(.medium)

                            Text("Add some subscriptions to see analytics")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
        }
    }

    private var categoryData: [CategoryData] {
        SubscriptionCategory.allCases.compactMap { category in
            let amount = selectedPeriod == .month ?
                subscriptionManager.monthlySpending(for: category) :
                subscriptionManager.monthlySpending(for: category) * 12
            return amount > 0 ? CategoryData(category: category, amount: amount) : nil
        }
    }

    private var mostExpensiveSubscription: String {
        subscriptionManager.activeSubscriptions
            .max { $0.monthlyPrice < $1.monthlyPrice }?.name ?? "N/A"
    }

    private var cheapestSubscription: String {
        subscriptionManager.activeSubscriptions
            .min { $0.monthlyPrice < $1.monthlyPrice }?.name ?? "N/A"
    }

    private var mostCommonBillingCycle: String {
        let cycles = subscriptionManager.activeSubscriptions.map { $0.billingCycle }
        let counts = Dictionary(grouping: cycles) { $0 }.mapValues { $0.count }
        return counts.max { $0.value < $1.value }?.key.rawValue ?? "N/A"
    }

    private var mostCommonCategory: String {
        let categories = subscriptionManager.activeSubscriptions.map { $0.category }
        let counts = Dictionary(grouping: categories) { $0 }.mapValues { $0.count }
        return counts.max { $0.value < $1.value }?.key.rawValue ?? "N/A"
    }
}

enum AnalyticsPeriod: String, CaseIterable {
    case month = "Month"
    case year = "Year"
}

struct CategoryData {
    let category: SubscriptionCategory
    let amount: Double
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct CategoryBreakdownRow: View {
    let category: SubscriptionCategory
    let amount: Double
    let percentage: Double
    let subscriptionCount: Int

    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(category.color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("\(subscriptionCount) subscription\(subscriptionCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.2f", amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(String(format: "%.1f%%", percentage))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct UpcomingRenewalRow: View {
    let subscription: Subscription

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(subscription.nextBillingDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.2f", subscription.price))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("\(subscription.daysUntilNextBilling) days")
                    .font(.caption)
                    .foregroundColor(subscription.daysUntilNextBilling <= 3 ? .orange : .secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatisticRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    AnalyticsView(subscriptionManager: SubscriptionManager())
}