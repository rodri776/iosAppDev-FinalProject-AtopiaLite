//
//  AuthManager.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI
import Combine

class AuthManager: ObservableObject {
    @Published var currentUser: LocalUser?
    @Published var allUsers: [LocalUser] = []
    
    var isAuthenticated: Bool { currentUser != nil }
    
    private let usersKey = "AtopiaLite.allUsers"
    private let currentUserIdKey = "AtopiaLite.currentUserId"
    
    init() {
        loadState()
    }
    
    // MARK: - Authentication
    
    func signUp(username: String, password: String, firstName: String, lastName: String) -> Result<LocalUser, AuthError> {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.emptyUsername)
        }
        guard !password.isEmpty else {
            return .failure(.emptyPassword)
        }
        guard !allUsers.contains(where: { $0.username.lowercased() == username.lowercased() }) else {
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
        return .success(user)
    }
    
    func login(username: String, password: String) -> Result<LocalUser, AuthError> {
        guard let user = allUsers.first(where: {
            $0.username.lowercased() == username.lowercased() &&
            $0.passwordHash == LocalUser.hashPassword(password)
        }) else {
            return .failure(.invalidCredentials)
        }
        currentUser = user
        saveState()
        return .success(user)
    }
    
    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: currentUserIdKey)
    }
    
    func updateCurrentUser(_ user: LocalUser) {
        currentUser = user
        if let index = allUsers.firstIndex(where: { $0.id == user.id }) {
            allUsers[index] = user
        }
        saveState()
    }
    
    // MARK: - Persistence
    
    private func loadState() {
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let users = try? JSONDecoder().decode([LocalUser].self, from: data) {
            allUsers = users
        }
        
        if let currentId = UserDefaults.standard.string(forKey: currentUserIdKey),
           let user = allUsers.first(where: { $0.id == currentId }) {
            currentUser = user
        }
    }
    
    private func saveState() {
        if let data = try? JSONEncoder().encode(allUsers) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
        UserDefaults.standard.set(currentUser?.id, forKey: currentUserIdKey)
    }
}

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
