//
//  ContactsOnboardingView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/9/26.
//

import SwiftUI
import Contacts
import CryptoKit

struct ContactsOnboardingView: View {
    /// Returns the set of SHA-256 hashed phone numbers from the user's address book.
    var onComplete: (Set<String>) -> Void

    @State private var hasSharedContacts = false
    @State private var isLoading = false
    @State private var contactCount = 0
    @State private var hashedPhones: Set<String> = []
    @State private var permissionDenied = false

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
                    Text("\(contactCount) contacts found")
                        .font(.headline)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.green.opacity(0.15))
                .clipShape(Capsule())
            }

            if permissionDenied {
                Text("Contact access denied. You can enable it in Settings.")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 16) {
                if !hasSharedContacts {
                    Button {
                        print("[Contacts] 'Share Contacts' button tapped")
                        fetchContacts()
                    } label: {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView().tint(.white)
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
                }

                Button {
                    print("[Contacts] '\(hasSharedContacts ? "Continue" : "Skip")' tapped")
                    onComplete(hashedPhones)
                } label: {
                    Text(hasSharedContacts ? "Continue" : "Skip")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(hasSharedContacts ? Color.blue.opacity(0.5) : Color(.systemGray5))
                        .foregroundStyle(.black)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 32)

            Spacer().frame(height: 24)
        }
        .padding()
        .background(Color("BackgroundColor").ignoresSafeArea())
    }

    private func fetchContacts() {
        isLoading = true
        permissionDenied = false

        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            if let error {
                print("[Contacts] ERROR requesting access: \(error.localizedDescription)")
            }

            guard granted else {
                DispatchQueue.main.async {
                    print("[Contacts] Access denied")
                    isLoading = false
                    permissionDenied = true
                }
                return
            }

            print("[Contacts] Access granted, fetching phone numbers")

            var hashed: Set<String> = []
            var count = 0

            let keys = [CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)

            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    for phone in contact.phoneNumbers {
                        let digits = Self.normalizePhone(phone.value.stringValue)
                        guard digits.count >= 7 else { continue }
                        hashed.insert(Self.sha256(digits))
                    }
                    count += 1
                }
            } catch {
                print("[Contacts] ERROR enumerating contacts: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                print("[Contacts] Scan complete: \(count) contacts, \(hashed.count) hashed phone numbers")
                self.contactCount = count
                self.hashedPhones = hashed
                self.hasSharedContacts = true
                self.isLoading = false
            }
        }
    }

    /// Strip everything except digits from a phone string.
    static func normalizePhone(_ raw: String) -> String {
        String(raw.unicodeScalars.filter(CharacterSet.decimalDigits.contains))
    }

    /// SHA-256 hash of a string, returned as lowercase hex.
    static func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
