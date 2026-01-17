import SwiftUI

struct CollapsibleDatePickerRow: View {
    let title: String
    let placeholder: String
    @Binding var date: Date?
    var minimumDate: Date?
    var maximumDate: Date?
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Spacer()
                if let value = date {
                    Text(value, style: .date)
                        .foregroundColor(.secondary)
                } else {
                    Text(placeholder)
                        .foregroundColor(.secondary)
                }
                Button(action: {
                    isExpanded.toggle()
                }) {
                    Image(systemName: "calendar")
                }
            }
            if isExpanded {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { date ?? Date() },
                        set: { newValue in
                            date = newValue
                            isExpanded = false
                        }
                    ),
                    in: (minimumDate ?? Date.distantPast)...(maximumDate ?? Date.distantFuture),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            }
        }
    }
}

