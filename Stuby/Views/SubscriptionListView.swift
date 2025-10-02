import SwiftUI

struct SubscriptionListView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @State private var searchText = ""
    @State private var selectedCategory: SubscriptionCategory?
    @State private var showingAddSubscription = false

    var filteredSubscriptions: [Subscription] {
        var subscriptions = subscriptionManager.activeSubscriptions

        if !searchText.isEmpty {
            subscriptions = subscriptions.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let category = selectedCategory {
            subscriptions = subscriptions.filter { $0.category == category }
        }

        return subscriptions.sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryFilterButton(
                            title: "All",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }

                        ForEach(SubscriptionCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                title: category.rawValue,
                                isSelected: selectedCategory == category,
                                icon: category.icon
                            ) {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                // Subscription List
                if filteredSubscriptions.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No subscriptions found")
                            .font(.title2)
                            .fontWeight(.medium)

                        Text("Tap the + button to add your first subscription")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Add Subscription") {
                            showingAddSubscription = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredSubscriptions) { subscription in
                            NavigationLink(
                                destination: SubscriptionDetailView(
                                    subscription: subscription,
                                    subscriptionManager: subscriptionManager
                                )
                            ) {
                                SubscriptionListRow(subscription: subscription)
                            }
                        }
                        .onDelete(perform: deleteSubscriptions)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .searchable(text: $searchText, prompt: "Search subscriptions")
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSubscription = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $showingAddSubscription) {
                AddEditSubscriptionView(subscriptionManager: subscriptionManager)
            }
        }
    }

    private func deleteSubscriptions(at offsets: IndexSet) {
        for index in offsets {
            let subscription = filteredSubscriptions[index]
            subscriptionManager.deleteSubscription(subscription)
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected ? Color.accentColor : Color(.systemGray5)
            )
            .foregroundColor(
                isSelected ? .white : .primary
            )
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SubscriptionListRow: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: subscription.category.icon)
                .font(.title2)
                .foregroundColor(subscription.category.color)
                .frame(width: 32, height: 32)
                .background(subscription.category.color.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name)
                    .font(.headline)
                    .fontWeight(.medium)

                HStack {
                    Text(subscription.billingCycle.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 3, height: 3)

                    Text(subscription.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", subscription.price))
                    .font(.headline)
                    .fontWeight(.semibold)

                if subscription.isOverdue {
                    Text("Overdue")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(4)
                } else if subscription.daysUntilNextBilling <= 3 {
                    Text("\(subscription.daysUntilNextBilling) days")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                } else {
                    Text("\(subscription.daysUntilNextBilling) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SubscriptionListView(subscriptionManager: SubscriptionManager())
}
