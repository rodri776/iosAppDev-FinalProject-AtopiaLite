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
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "location.circle")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(.green)

            Text("Share Your Location")
                .font(.largeTitle.bold())

            Text("Helps connect you with nearby people")
                .foregroundStyle(.secondary)

            if let city = locationFetcher.city, let state = locationFetcher.state {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill").foregroundStyle(.green)
                    Text("\(city), \(state)").font(.headline)
                }
                .padding(.horizontal, 20).padding(.vertical, 10)
                .background(Color.green.opacity(0.15))
                .clipShape(Capsule())
            }

            VStack(spacing: 16) {
                if !locationFetcher.locationObtained {
                    Button { locationFetcher.requestLocation() } label: {
                        HStack(spacing: 8) {
                            if locationFetcher.isRequesting {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "location.fill")
                            }
                            Text(locationFetcher.isRequesting ? "Getting Location..." : "Share Location")
                        }
                        .font(.headline).frame(maxWidth: .infinity).padding()
                        .background(Color.green).foregroundStyle(.white).clipShape(Capsule())
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
                        .font(.title3.bold()).frame(maxWidth: .infinity).padding()
                        .background(locationFetcher.locationObtained ? Color.green.opacity(0.5) : Color(.systemGray5))
                        .foregroundStyle(.black).clipShape(Capsule())
                }
            }
            .padding(.horizontal, 32)

            Spacer().frame(height: 24)
        }
        .padding()
        .background(Color("BackgroundColor").ignoresSafeArea())
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
        
        #if targetEnvironment(simulator)
        // Simulate location fetch for demo on simulator
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            self.latitude = 41.8781
            self.longitude = -87.6298
            self.city = "Chicago"
            self.state = "IL"
            self.locationObtained = true
            self.isRequesting = false
        }
        #else
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else {
            manager.requestWhenInUseAuthorization()
        }
        #endif
    }

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
