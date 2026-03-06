//
//  ProfileGraphView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI

struct ProfileGraphView: View {
    let profileManager: UserProfileManager
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.primary.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.1))
            )
            .padding()
    }
}
