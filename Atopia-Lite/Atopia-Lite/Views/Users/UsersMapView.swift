//
//  UsersMapView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI
import MapKit

struct UsersMapView: View {
    let results: [SimilarityService.UserSimilarityResult]
    
    var body: some View {
        Map {
            ForEach(results) { result in
                if let lat = result.user.latitude, let lon = result.user.longitude {
                    Annotation(
                        result.user.displayName,
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    ) {
                        UserMapAnnotation(result: result)
                    }
                }
            }
        }
        .mapStyle(.standard)
    }
}

struct UserMapAnnotation: View {
    let result: SimilarityService.UserSimilarityResult
    @State private var showDetail = false
    
    var body: some View {
        VStack(spacing: 4) {
            if showDetail {
                VStack(spacing: 4) {
                    Text(result.user.displayName)
                        .font(.caption)
                        .fontWeight(.bold)
                    
                    Text("@\(result.user.username)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if let neighborhood = result.user.neighborhood {
                        Text(neighborhood)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(result.percentageSimilarity)% similar")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                    
                    Text("\(result.datapointsInCommon.count) in common")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("BackgroundColor"))
                        .shadow(radius: 4)
                )
            }
            
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 36, height: 36)
                
                Text(String(result.user.firstName.prefix(1)))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showDetail.toggle()
            }
        }
    }
}
