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
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                        
                        Text("Lite")
                            .font(.system(size: 20, weight: .bold, design: .serif)).italic(true)
                            .padding(.bottom)
                    }
                    
                    Text(isSignUp ? "Create your account" : "Welcome back")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Form
                VStack(spacing: 16) {
                    if isSignUp {
                        HStack(spacing: 12) {
                            AuthTextField("First Name", text: $firstName)
                                .textContentType(.givenName)
                                .autocorrectionDisabled()
                            
                            AuthTextField("Last Name", text: $lastName)
                                .textContentType(.familyName)
                                .autocorrectionDisabled()
                        }
                    }
                    
                    AuthTextField("Username", text: $username)
                        .textContentType(.username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    AuthTextField("Password", text: $password, isSecure: true)
                        .textContentType(isSignUp ? .newPassword : .password)
                }
                .padding(.horizontal, 40)
                
                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Action Button
                Button {
                    performAction()
                } label: {
                    Text(isSignUp ? "Sign Up" : "Log In")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundColor(.black)
                        .background(Color.green)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 40)
                
                // Toggle
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSignUp.toggle()
                        errorMessage = nil
                    }
                } label: {
                    Text(isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
                
                Spacer()
            }
        }
        .fontDesign(.serif)
    }
    
    private func performAction() {
        errorMessage = nil
        
        if isSignUp {
            guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty,
                  !lastName.trimmingCharacters(in: .whitespaces).isEmpty else {
                errorMessage = "Please enter your first and last name"
                return
            }
            
            let result = authManager.signUp(
                username: username,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
            if case .failure(let error) = result {
                errorMessage = error.localizedDescription
            }
        } else {
            let result = authManager.login(username: username, password: password)
            if case .failure(let error) = result {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Auth Text Field (matches onboarding style)
private struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    init(_ placeholder: String, text: Binding<String>, isSecure: Bool = false) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
    }
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(.body)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

