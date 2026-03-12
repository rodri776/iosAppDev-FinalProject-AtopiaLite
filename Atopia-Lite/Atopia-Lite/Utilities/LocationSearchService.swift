//
//  LocationSearchService.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/11/26.
//

import Foundation
import MapKit

@Observable
class LocationSearchService: NSObject, MKLocalSearchCompleterDelegate {
    var queryFragment: String = "" {
        didSet {
            if queryFragment.isEmpty {
                results = []
            } else {
                completer.queryFragment = queryFragment
            }
        }
    }
    var results: [MKLocalSearchCompletion] = []
    var selectedMapItem: MKMapItem?

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .pointOfInterest
    }

    func selectCompletion(_ completion: MKLocalSearchCompletion) async {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            if let item = response.mapItems.first {
                selectedMapItem = item
                queryFragment = completion.title
                results = []
            }
        } catch {
            print("[LocationSearch] Error resolving completion: \(error)")
        }
    }

    // MARK: - MKLocalSearchCompleterDelegate

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("[LocationSearch] Completer error: \(error)")
    }
}
