//
//  AuthView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isSignUp = false
    @State private var username = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var errorMessage: String?
    @State private var showSavePasswordAlert = false
    @State private var pendingPassword = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                HStack {
                    Image("Logo").resizable().scaledToFit()
                        .frame(width: 150, height: 150)
                    Text("Lite")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .italic(true).padding(.bottom)
                }
                if isSignUp {
                    Text("Create your account")
                        .font(.title3).foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 12) {
                if isSignUp {
                    HStack(spacing: 12) {
                        TextField("First Name", text: $firstName).fieldStyle()
                        TextField("Last Name", text: $lastName).fieldStyle()
                    }
                }
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .fieldStyle()
                SecureField("Password", text: $password).fieldStyle()
            }
            .padding(.horizontal, 32)

            if let errorMessage {
                Text(errorMessage).font(.caption).foregroundStyle(.red)
                    .multilineTextAlignment(.center).padding(.horizontal, 32)
            }

            VStack(spacing: 16) {
                Button { performAction() } label: {
                    Text(isSignUp ? "Sign Up" : "Log In")
                        .font(.title3.bold()).frame(maxWidth: .infinity).padding()
                        .background(Color.green).foregroundStyle(.black).clipShape(Capsule())
                }

                Button {
                    withAnimation { isSignUp.toggle(); errorMessage = nil }
                } label: {
                    Text(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)

            Spacer().frame(height: 24)
        }
        .padding()
        .background(Color("BackgroundColor").ignoresSafeArea())
        .onAppear {
            if let creds = KeychainHelper.retrieve() {
                username = creds.username
                password = creds.password
            }
        }
        .alert("Save Password?", isPresented: $showSavePasswordAlert) {
            Button("Save to Device") {
                KeychainHelper.save(username: username, password: pendingPassword)
            }
            Button("Not Now", role: .cancel) { }
        } message: {
            Text("Save your password to this device for faster login next time.")
        }
    }

    private func performAction() {
        errorMessage = nil
        if isSignUp {
            guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty,
                  !lastName.trimmingCharacters(in: .whitespaces).isEmpty else {
                errorMessage = "Please enter your first and last name"; return
            }
            switch authManager.signUp(username: username, password: password, firstName: firstName, lastName: lastName) {
            case .success:
                pendingPassword = password
                showSavePasswordAlert = true
            case .failure(let e):
                errorMessage = e.localizedDescription
            }
        } else {
            if case .failure(let e) = authManager.login(username: username, password: password) {
                errorMessage = e.localizedDescription
            }
        }
    }
}
