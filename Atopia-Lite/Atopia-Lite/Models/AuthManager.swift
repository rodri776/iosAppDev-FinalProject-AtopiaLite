//
//  AuthManager.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI
import Combine

/// Handles sign-up, login, logout, and session persistence via UserDefaults.
class AuthManager: ObservableObject {
    @Published var currentUser: LocalUser?
    @Published var allUsers: [LocalUser] = []
    
    var isAuthenticated: Bool { currentUser != nil }
    
    private let usersKey = "AtopiaLite.allUsers"
    private let currentUserIdKey = "AtopiaLite.currentUserId"
    
    init() {
        print("[Auth] AuthManager initializing, loading state from UserDefaults")
        loadState()
    }
    
    /// Creates a new user account and logs them in.
    func signUp(username: String, password: String, firstName: String, lastName: String) -> Result<LocalUser, AuthError> {
        print("[Auth] Sign-up attempt for username: \(username)")
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("[Auth] Sign-up failed: empty username")
            return .failure(.emptyUsername)
        }
        guard !password.isEmpty else {
            print("[Auth] Sign-up failed: empty password")
            return .failure(.emptyPassword)
        }
        guard !allUsers.contains(where: { $0.username.lowercased() == username.lowercased() }) else {
            print("[Auth] Sign-up failed: username '\(username)' already taken")
            return .failure(.usernameTaken)
        }
        
        let user = LocalUser(
            id: UUID().uuidString,
            username: username.trimmingCharacters(in: .whitespaces),
            passwordHash: LocalUser.hashPassword(password),
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            savedDatapoints: [],
            hasCompletedOnboarding: false
        )
        allUsers.append(user)
        currentUser = user
        saveState()
        print("[Auth] Sign-up success: userId=\(user.id), username=\(user.username)")
        return .success(user)
    }
    
    /// Authenticates against stored credentials and sets the active session.
    func login(username: String, password: String) -> Result<LocalUser, AuthError> {
        print("[Auth] Login attempt for username: \(username)")
        guard let user = allUsers.first(where: {
            $0.username.lowercased() == username.lowercased() &&
            $0.passwordHash == LocalUser.hashPassword(password)
        }) else {
            print("[Auth] Login failed: invalid credentials for '\(username)'")
            return .failure(.invalidCredentials)
        }
        currentUser = user
        saveState()
        print("[Auth] Login success: userId=\(user.id), username=\(user.username)")
        return .success(user)
    }
    
    func logout() {
        print("[Auth] Logout: userId=\(currentUser?.id ?? "nil"), clearing UserDefaults key '\(currentUserIdKey)' and Keychain")
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: currentUserIdKey)
        KeychainHelper.delete()
    }
    
    /// Persists changes to the current user (e.g. after saving datapoints or finishing onboarding).
    func updateCurrentUser(_ user: LocalUser) {
        print("[Auth] Updating user: userId=\(user.id), onboarded=\(user.hasCompletedOnboarding), datapoints=\(user.savedDatapoints.count)")
        currentUser = user
        if let index = allUsers.firstIndex(where: { $0.id == user.id }) {
            allUsers[index] = user
        }
        saveState()
    }
    
    private func loadState() {
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let users = try? JSONDecoder().decode([LocalUser].self, from: data) {
            allUsers = users
            print("[Auth] Loaded \(users.count) users from UserDefaults key '\(usersKey)'")
        } else {
            print("[Auth] No saved users found in UserDefaults key '\(usersKey)'")
        }
        
        if let currentId = UserDefaults.standard.string(forKey: currentUserIdKey),
           let user = allUsers.first(where: { $0.id == currentId }) {
            currentUser = user
            print("[Auth] Restored session for userId=\(currentId), username=\(user.username)")
        } else {
            print("[Auth] No active session found in UserDefaults key '\(currentUserIdKey)'")
        }
    }
    
    private func saveState() {
        if let data = try? JSONEncoder().encode(allUsers) {
            UserDefaults.standard.set(data, forKey: usersKey)
            print("[Auth] Saved \(allUsers.count) users to UserDefaults key '\(usersKey)'")
        } else {
            print("[Auth] ERROR: Failed to encode users for UserDefaults")
        }
        UserDefaults.standard.set(currentUser?.id, forKey: currentUserIdKey)
        print("[Auth] Saved currentUserId=\(currentUser?.id ?? "nil") to UserDefaults key '\(currentUserIdKey)'")
    }
}

/// Auth failures surfaced to the UI as alerts.
enum AuthError: Error, LocalizedError {
    case usernameTaken
    case invalidCredentials
    case emptyUsername
    case emptyPassword
    
    var errorDescription: String? {
        switch self {
        case .usernameTaken: return "Username is already taken"
        case .invalidCredentials: return "Invalid username or password"
        case .emptyUsername: return "Username cannot be empty"
        case .emptyPassword: return "Password cannot be empty"
        }
    }
}
