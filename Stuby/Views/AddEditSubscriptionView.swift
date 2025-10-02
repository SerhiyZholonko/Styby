import SwiftUI

struct AddEditSubscriptionView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss

    var subscription: Subscription?

    @State private var name = ""
    @State private var price = ""
    @State private var billingCycle = BillingCycle.monthly
    @State private var category = SubscriptionCategory.other
    @State private var nextBillingDate = Date()
    @State private var isActive = true
    @State private var notes = ""
    @State private var selectedColor = "blue"
    @State private var repetitionType = RepetitionType.monthly

    private let colors = ["blue", "red", "green", "orange", "purple", "pink", "yellow", "indigo", "teal", "mint"]

    var isEditing: Bool {
        subscription != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Subscription Details") {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(category.color)
                            .font(.title2)

                        TextField("Subscription name", text: $name)
                            .textFieldStyle(.plain)
                    }

                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $price)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.plain)
                    }

                    Picker("Billing Cycle", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.rawValue).tag(cycle)
                        }
                    }

                    Picker("Category", selection: $category) {
                        ForEach(SubscriptionCategory.allCases, id: \.self) { cat in
                            HStack {
                                Image(systemName: cat.icon)
                                Text(cat.rawValue)
                            }
                            .tag(cat)
                        }
                    }
                }

                Section("Billing Information") {
                    DatePicker("Next billing date", selection: $nextBillingDate, displayedComponents: .date)

                    Toggle("Active subscription", isOn: $isActive)
                }

                Section("Payment Repetition") {
                    Picker("Auto-renewal", selection: $repetitionType) {
                        ForEach(RepetitionType.allCases, id: \.self) { type in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.rawValue)
                                    .font(.body)
                                Text(type.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.automatic)

                    if repetitionType != .disabled {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text("Payments will automatically renew based on your selection")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("This subscription will not auto-renew")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section("Appearance") {
                    HStack {
                        Text("Color")
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(colors, id: \.self) { color in
                                    Circle()
                                        .fill(Color(color))
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                        )
                                        .onTapGesture {
                                            selectedColor = color
                                        }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }

                Section("Notes") {
                    TextField("Add notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if isEditing {
                    Section {
                        Button("Delete Subscription", role: .destructive) {
                            if let subscription = subscription {
                                subscriptionManager.deleteSubscription(subscription)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Subscription" : "Add Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSubscription()
                    }
                    .disabled(name.isEmpty || price.isEmpty)
                }
            }
            .onAppear {
                loadSubscription()
            }
        }
    }

    private func loadSubscription() {
        guard let subscription = subscription else { return }

        name = subscription.name
        price = String(format: "%.2f", subscription.price)
        billingCycle = subscription.billingCycle
        category = subscription.category
        nextBillingDate = subscription.nextBillingDate
        isActive = subscription.isActive
        notes = subscription.notes
        selectedColor = subscription.color
        repetitionType = subscription.repetitionType
    }

    private func saveSubscription() {
        guard let priceValue = Double(price) else { return }

        if isEditing, var existingSubscription = subscription {
            existingSubscription.name = name
            existingSubscription.price = priceValue
            existingSubscription.billingCycle = billingCycle
            existingSubscription.category = category
            existingSubscription.nextBillingDate = nextBillingDate
            existingSubscription.isActive = isActive
            existingSubscription.notes = notes
            existingSubscription.color = selectedColor
            existingSubscription.repetitionType = repetitionType

            subscriptionManager.updateSubscription(existingSubscription)
        } else {
            let newSubscription = Subscription(
                name: name,
                price: priceValue,
                billingCycle: billingCycle,
                category: category,
                nextBillingDate: nextBillingDate,
                isActive: isActive,
                notes: notes,
                color: selectedColor,
                repetitionType: repetitionType
            )

            subscriptionManager.addSubscription(newSubscription)
        }

        dismiss()
    }
}

#Preview {
    AddEditSubscriptionView(subscriptionManager: SubscriptionManager())
}