//
//  LocationOnboardingView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI
import CoreLocation
import Combine

struct LocationOnboardingView: View {
    @StateObject private var locationFetcher = LocationFetcher()
    
    var onComplete: (String?, String?, Double?, Double?) -> Void
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                Image(systemName: "location.circle")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(.tint)
                
                VStack(spacing: 12) {
                    Text("Share Your Location")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                    
                    Text("Your location helps connect you with nearby users. It's stored on your device only.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                if let city = locationFetcher.city, let state = locationFetcher.state {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.accentColor)
                        Text("\(city), \(state)")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor.opacity(0.1))
                    )
                }
                
                VStack(spacing: 16) {
                    if !locationFetcher.locationObtained {
                        Button {
                            locationFetcher.requestLocation()
                        } label: {
                            HStack(spacing: 8) {
                                if locationFetcher.isRequesting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "location.fill")
                                }
                                Text(locationFetcher.isRequesting ? "Getting Location..." : "Share Location")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.accentColor)
                            )
                        }
                        .disabled(locationFetcher.isRequesting)
                    }
                    
                    Button {
                        if locationFetcher.locationObtained {
                            onComplete(locationFetcher.city, locationFetcher.state, locationFetcher.latitude, locationFetcher.longitude)
                        } else {
                            onComplete(nil, nil, nil, nil)
                        }
                    } label: {
                        Text(locationFetcher.locationObtained ? "Continue" : "Skip")
                            .font(.headline)
                            .foregroundColor(locationFetcher.locationObtained ? .white : .accentColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(locationFetcher.locationObtained ? Color.accentColor : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.accentColor, lineWidth: locationFetcher.locationObtained ? 0 : 1.5)
                                    )
                            )
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
    }
}

// MARK: - One-shot location fetcher

private class LocationFetcher: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var isRequesting = false
    @Published var locationObtained = false
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var city: String?
    @Published var state: String?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocation() {
        isRequesting = true
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if isRequesting && (status == .authorizedWhenInUse || status == .authorizedAlways) {
            manager.requestLocation()
        } else if status == .denied || status == .restricted {
            isRequesting = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        // Reverse geocode for display
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self, let placemark = placemarks?.first else { return }
            self.city = placemark.locality
            self.state = placemark.administrativeArea
            self.locationObtained = true
            self.isRequesting = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        isRequesting = false
    }
}
