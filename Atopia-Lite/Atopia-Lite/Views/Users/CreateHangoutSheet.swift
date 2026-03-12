//
//  CreateHangoutSheet.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/11/26.
//

import SwiftUI
import MapKit
import EventKit
import MessageUI

struct CreateHangoutSheet: View {
    let userName: String
    let phoneNumber: String?
    @Environment(\.dismiss) private var dismiss

    @State private var activity = ""
    @State private var description = ""
    @State private var eventDate = Date().addingTimeInterval(3600)
    @State private var locationService = LocationSearchService()
    @State private var showMessageCompose = false

    private let eventStore = EKEventStore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Activity")
                            .font(.subheadline.bold())
                        TextField("What's the plan?", text: $activity)
                            .fieldStyle()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Venue / Location")
                            .font(.subheadline.bold())

                        TextField("Search for a place", text: $locationService.queryFragment)
                            .fieldStyle()

                        if !locationService.results.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(locationService.results, id: \.self) { completion in
                                    Button {
                                        Task {
                                            await locationService.selectCompletion(completion)
                                        }
                                    } label: {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(completion.title)
                                                .font(.subheadline)
                                                .foregroundStyle(.primary)
                                            if !completion.subtitle.isEmpty {
                                                Text(completion.subtitle)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 16)
                                    }
                                    .accessibilityElement(children: .ignore)
                                    .accessibilityLabel("\(completion.title), \(completion.subtitle)")
                                    .accessibilityHint("Selects this location")
                                    Divider()
                                }
                            }
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        if let mapItem = locationService.selectedMapItem {
                            Map {
                                Marker(
                                    mapItem.name ?? "Location",
                                    coordinate: mapItem.location.coordinate
                                )
                            }
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .allowsHitTesting(false)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Map showing \(mapItem.name ?? "selected location")")
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.subheadline.bold())
                        TextField("Add a note...", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                            .fieldStyle()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date & Time")
                            .font(.subheadline.bold())
                        DatePicker("", selection: $eventDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .fieldStyle()
                    }

                    Button {
                        sendInvite()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                                .font(.subheadline.bold())
                            Text("Send Invite")
                                .font(.subheadline.bold())
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("SavedGreen"))
                        .clipShape(Capsule())
                    }
                    .disabled(activity.isEmpty)
                    .opacity(activity.isEmpty ? 0.5 : 1)
                    .accessibilityHint(activity.isEmpty ? "Enter an activity name first" : "Sends a message invite to \(userName)")
                }
                .padding(20)
            }
            .background(Color("BackgroundColor"))
            .navigationTitle("Create Hangout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Close")
                }
            }
            .sheet(isPresented: $showMessageCompose) {
                MessageComposeView(
                    recipients: phoneNumber.map { [$0] } ?? [],
                    body: buildMessageBody()
                )
            }
        }
    }

    private func sendInvite() {
        Task {
            await saveCalendarEvent()

            if MFMessageComposeViewController.canSendText() {
                showMessageCompose = true
            } else if let phone = phoneNumber,
                      let encoded = buildMessageBody().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let url = URL(string: "sms:\(phone)&body=\(encoded)") {
                await UIApplication.shared.open(url)
            }
        }
    }

    private func saveCalendarEvent() async {
        do {
            let granted = try await eventStore.requestWriteOnlyAccessToEvents()
            guard granted else { return }

            let event = EKEvent(eventStore: eventStore)
            event.title = activity
            event.startDate = eventDate
            event.endDate = eventDate.addingTimeInterval(3600)
            event.notes = description.isEmpty ? nil : description
            event.calendar = eventStore.defaultCalendarForNewEvents

            if let mapItem = locationService.selectedMapItem {
                let location = EKStructuredLocation(title: mapItem.name ?? locationService.queryFragment)
                location.geoLocation = mapItem.location
                event.structuredLocation = location
            }

            try eventStore.save(event, span: .thisEvent)
            print("[CreateHangout] Calendar event saved: \(activity)")
        } catch {
            print("[CreateHangout] Failed to save calendar event: \(error)")
        }
    }

    private func buildMessageBody() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        var lines: [String] = []
        lines.append("Let's hang out! \(activity)")
        if let mapItem = locationService.selectedMapItem, let name = mapItem.name {
            lines.append("Where: \(name)")
        }
        lines.append("When: \(formatter.string(from: eventDate))")
        if !description.isEmpty {
            lines.append(description)
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - MessageComposeView

struct MessageComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let body: String
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.recipients = recipients
        controller.body = body
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true) {
                self.dismiss()
            }
        }
    }
}
