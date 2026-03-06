//
//  LocalUser.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import Foundation
import CryptoKit

struct LocalUser: Codable, Identifiable {
    let id: String
    var username: String
    var passwordHash: String
    var firstName: String
    var lastName: String
    var bio: String?
    var latitude: Double?
    var longitude: Double?
    var city: String?
    var neighborhood: String?
    var state: String?
    var savedDatapoints: [String]
    var hasCompletedOnboarding: Bool
    
    var displayName: String { "\(firstName) \(lastName)" }
    
    var abbreviatedName: String {
        guard let initial = lastName.first else { return firstName }
        return "\(firstName) \(initial)."
    }
    
    var locationString: String? {
        if let neighborhood, let city {
            return "\(neighborhood), \(city)"
        } else if let city, let state {
            return "\(city), \(state)"
        } else if let city {
            return city
        } else if let state {
            return state
        }
        return nil
    }
    
    static func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
