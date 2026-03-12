//
//  ContactsOnboardingView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/9/26.
//

import SwiftUI

struct ContactsOnboardingView: View {
    var onComplete: () -> Void

    @State private var hasSharedContacts = false
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.crop.rectangle.stack.fill")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(.blue)

            Text("Share Contacts")
                .font(.largeTitle.bold())

            Text("Find people you know on Atopia")
                .foregroundStyle(.secondary)

            if hasSharedContacts {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("24 contacts found")
                        .font(.headline)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.green.opacity(0.15))
                .clipShape(Capsule())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("24 contacts found")
            }

            VStack(spacing: 16) {
                if !hasSharedContacts {
                    Button {
                        simulateContactSharing()
                    } label: {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .accessibilityLabel("Finding contacts")
                            } else {
                                Image(systemName: "person.2.fill")
                            }
                            Text(isLoading ? "Finding Contacts..." : "Share Contacts")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                    .disabled(isLoading)
                    .accessibilityLabel(isLoading ? "Finding contacts, please wait" : "Share Contacts")
                }

                if hasSharedContacts {
                    Button {
                        onComplete()
                    } label: {
                        Text("Continue")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.5))
                            .foregroundStyle(.black)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 32)

            Spacer().frame(height: 24)
        }
        .padding()
        .background(Color("BackgroundColor").ignoresSafeArea())
    }

    private func simulateContactSharing() {
        isLoading = true
        // Simulate a brief delay for the "scan"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            hasSharedContacts = true
            isLoading = false
            print("[Contacts] Simulated contact sharing complete")
        }
    }
}
