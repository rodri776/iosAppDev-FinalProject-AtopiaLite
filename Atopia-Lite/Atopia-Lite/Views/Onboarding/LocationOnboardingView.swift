//
//  LocationOnboardingView.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/5/26.
//

import SwiftUI
import CoreLocation
import Combine
import MapKit

/// Onboarding step that requests the user's location and reverse-geocodes it into city/state.
struct LocationOnboardingView: View {
    @StateObject private var locationFetcher = LocationFetcher()
    var onComplete: (String?, String?, String?, Double?, Double?) -> Void

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
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Location set to \(city), \(state)")
            }

            VStack(spacing: 16) {
                if !locationFetcher.locationObtained {
                    Button { locationFetcher.requestLocation() } label: {
                        HStack(spacing: 8) {
                            if locationFetcher.isRequesting {
                                ProgressView()
                                    .tint(.white)
                                    .accessibilityLabel("Getting location")
                            } else {
                                Image(systemName: "location.fill")
                            }
                            Text(locationFetcher.isRequesting ? "Getting Location..." : "Share Location")
                        }
                        .font(.headline).frame(maxWidth: .infinity).padding()
                        .background(Color.green).foregroundStyle(.white).clipShape(Capsule())
                    }
                    .disabled(locationFetcher.isRequesting)
                    .accessibilityLabel(locationFetcher.isRequesting ? "Getting location, please wait" : "Share Location")
                }

                if locationFetcher.locationObtained {
                    Button {
                        print("[Location] 'Continue' tapped — passing location: city=\(locationFetcher.city ?? "nil"), state=\(locationFetcher.state ?? "nil"), neighborhood=\(locationFetcher.neighborhood ?? "nil"), lat=\(locationFetcher.latitude ?? 0), lon=\(locationFetcher.longitude ?? 0)")
                        onComplete(locationFetcher.city, locationFetcher.state, locationFetcher.neighborhood, locationFetcher.latitude, locationFetcher.longitude)
                    } label: {
                        Text("Continue")
                            .font(.title3.bold()).frame(maxWidth: .infinity).padding()
                            .background(Color.green.opacity(0.5))
                            .foregroundStyle(.black).clipShape(Capsule())
                    }
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

/// One-shot CLLocationManager wrapper that grabs the device location and reverse-geocodes it.
private class LocationFetcher: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var isRequesting = false
    @Published var locationObtained = false
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var city: String?
    @Published var state: String?
    @Published var neighborhood: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// Kicks off a location request (or uses hardcoded coords on the simulator).
    func requestLocation() {
        print("[Location] 'Share Location' button tapped, requesting location")
        isRequesting = true
        
        #if targetEnvironment(simulator)
        // Simulate location fetch for demo on simulator
        print("[Location] Running on simulator — using simulated Chicago coordinates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            self.latitude = 41.8781
            self.longitude = -87.6298
            self.city = "Chicago"
            self.state = "IL"
            self.neighborhood = "The Loop"
            self.locationObtained = true
            self.isRequesting = false
            print("[Location] Simulated location: lat=41.8781, lon=-87.6298, city=Chicago, state=IL, neighborhood=The Loop")
        }
        #else
        let status = manager.authorizationStatus
        print("[Location] Authorization status: \(status.rawValue)")
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else {
            print("[Location] Requesting location authorization")
            manager.requestWhenInUseAuthorization()
        }
        #endif
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        print("[Location] Authorization changed: status=\(status.rawValue)")
        if isRequesting && (status == .authorizedWhenInUse || status == .authorizedAlways) {
            print("[Location] Authorized — requesting location")
            manager.requestLocation()
        } else if status == .denied || status == .restricted {
            print("[Location] Authorization denied/restricted")
            isRequesting = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        print("[Location] Location received: lat=\(location.coordinate.latitude), lon=\(location.coordinate.longitude)")

        print("[Location] Starting reverse geocode")
        if #available(iOS 26.0, *) {
            guard let request = MKReverseGeocodingRequest(location: location) else {
                isRequesting = false
                return
            }
            Task { @MainActor in
                do {
                    let items = try await request.mapItems
                    guard let mapItem = items.first,
                          let addrReps = mapItem.addressRepresentations else {
                        self.isRequesting = false
                        return
                    }
                    self.city = addrReps.cityName
                    self.state = addrReps.regionName
                    self.neighborhood = nil
                    self.locationObtained = true
                    self.isRequesting = false
                    print("[Location] Reverse geocode result: city=\(addrReps.cityName ?? "nil"), region=\(addrReps.regionName ?? "nil")")
                } catch {
                    print("[Location] Reverse geocode error: \(error.localizedDescription)")
                    self.isRequesting = false
                }
            }
        } else {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
                guard let self, let placemark = placemarks?.first else { return }
                self.city = placemark.locality
                self.state = placemark.administrativeArea
                self.neighborhood = placemark.subLocality
                self.locationObtained = true
                self.isRequesting = false
                print("[Location] Reverse geocode result: city=\(placemark.locality ?? "nil"), state=\(placemark.administrativeArea ?? "nil"), neighborhood=\(placemark.subLocality ?? "nil")")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[Location] ERROR: \(error.localizedDescription)")
        isRequesting = false
    }
}
