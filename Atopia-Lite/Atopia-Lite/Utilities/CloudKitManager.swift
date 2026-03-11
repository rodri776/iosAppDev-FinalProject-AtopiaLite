//
//  CloudKitManager.swift
//  Atopia-Lite
//
//  Created by Juniper Rodriguez on 3/11/26.
//

import Foundation
import CloudKit

/// Minimal CloudKit public-database layer.
///
/// Each user gets one "UserProfile" record in the **public** database containing:
///   • `hashedPhone`  — SHA-256 of their normalized phone number (or empty)
///   • `datapoints`   — plain-text array of datapoint labels
///   • `userId`       — local UUID string (not PII)
///
/// No names, locations, or other PII ever leave the device.
actor CloudKitManager {
    static let shared = CloudKitManager()

    private let container = CKContainer(identifier: "iCloud.Juniper.Atopia-Lite")
    private var db: CKDatabase { container.publicCloudDatabase }

    private let recordType = "UserProfile"

    // MARK: - Publish

    /// Upsert the current user's public profile record.
    func publishProfile(
        userId: String,
        hashedPhone: String?,
        datapointLabels: [String]
    ) async {
        print("[CloudKit] Publishing profile for userId=\(userId), hashedPhone=\(hashedPhone != nil), datapoints=\(datapointLabels.count)")

        do {
            // Try to fetch an existing record first
            let existing = try await fetchRecord(userId: userId)

            if let record = existing {
                // Update in place
                record["hashedPhone"] = (hashedPhone ?? "") as CKRecordValue
                record["datapoints"] = datapointLabels as CKRecordValue
                try await db.save(record)
                print("[CloudKit] Updated existing record for userId=\(userId)")
            } else {
                // Create new
                let record = CKRecord(recordType: recordType)
                record["userId"] = userId as CKRecordValue
                record["hashedPhone"] = (hashedPhone ?? "") as CKRecordValue
                record["datapoints"] = datapointLabels as CKRecordValue
                try await db.save(record)
                print("[CloudKit] Created new record for userId=\(userId)")
            }
        } catch {
            print("[CloudKit] ERROR publishing profile: \(error.localizedDescription)")
        }
    }

    // MARK: - Discover

    /// Find UserProfile records whose `hashedPhone` matches any in the provided set.
    /// Returns an array of `(userId, datapointLabels)`.
    func discoverUsers(
        matchingHashedPhones phones: Set<String>
    ) async -> [(userId: String, datapoints: [String])] {
        guard !phones.isEmpty else { return [] }
        print("[CloudKit] Discovering users matching \(phones.count) hashed phones")

        var results: [(userId: String, datapoints: [String])] = []

        // CloudKit IN predicate supports up to ~250 values; batch if needed.
        let batches = Array(phones).chunked(into: 250)
        for batch in batches {
            let predicate = NSPredicate(format: "hashedPhone IN %@", batch)
            let query = CKQuery(recordType: recordType, predicate: predicate)

            do {
                let (records, _) = try await db.records(matching: query)
                for (_, result) in records {
                    if case .success(let record) = result {
                        let uid = record["userId"] as? String ?? ""
                        let dps = record["datapoints"] as? [String] ?? []
                        results.append((userId: uid, datapoints: dps))
                    }
                }
            } catch {
                print("[CloudKit] ERROR querying batch: \(error.localizedDescription)")
            }
        }

        print("[CloudKit] Discovered \(results.count) matching users")
        return results
    }

    // MARK: - Sync datapoints

    /// Update only the datapoints field for an existing profile.
    func syncDatapoints(userId: String, datapointLabels: [String]) async {
        print("[CloudKit] Syncing \(datapointLabels.count) datapoints for userId=\(userId)")
        do {
            if let record = try await fetchRecord(userId: userId) {
                record["datapoints"] = datapointLabels as CKRecordValue
                try await db.save(record)
                print("[CloudKit] Datapoints synced")
            } else {
                // No record yet — create a minimal one
                await publishProfile(userId: userId, hashedPhone: nil, datapointLabels: datapointLabels)
            }
        } catch {
            print("[CloudKit] ERROR syncing datapoints: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch single record

    /// Fetch the first UserProfile record matching `userId`.
    func fetchRecord(userId: String) async throws -> CKRecord? {
        let predicate = NSPredicate(format: "userId == %@", userId)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let (records, _) = try await db.records(matching: query, resultsLimit: 1)
        for (_, result) in records {
            if case .success(let record) = result {
                return record
            }
        }
        return nil
    }
}

// MARK: - Array chunking helper

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
