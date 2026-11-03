import Foundation
import SwiftData
import CoreLocation

enum WaypointError: LocalizedError {
    case emptyName
    case invalidLocation
    case staleLocation

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Please enter a waypoint name."

        case .invalidLocation:
            return "A usable location is not available yet."

        case .staleLocation:
            return "The location is out of date. Wait for a fresh GPS fix."
        }
    }
}

@MainActor
enum WaypointStore {
    static func isUsable(_ location: CLLocation) -> Bool {
        CLLocationCoordinate2DIsValid(location.coordinate)
            && location.horizontalAccuracy >= 0
            && abs(location.timestamp.timeIntervalSinceNow) <= 60
    }

    @discardableResult
    static func save(
        name: String,
        location: CLLocation,
        context: ModelContext
    ) throws -> Waypoint {
        let trimmedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            throw WaypointError.emptyName
        }

        guard CLLocationCoordinate2DIsValid(location.coordinate),
              location.horizontalAccuracy >= 0 else {
            throw WaypointError.invalidLocation
        }

        guard abs(location.timestamp.timeIntervalSinceNow) <= 60 else {
            throw WaypointError.staleLocation
        }

        let waypoint = Waypoint(
            name: trimmedName,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            locationTimestamp: location.timestamp,
            horizontalAccuracy: location.horizontalAccuracy
        )

        context.insert(waypoint)

        do {
            try context.save()
            return waypoint
        } catch {
            context.rollback()
            throw error
        }
    }

    static func delete(
        _ waypoint: Waypoint,
        context: ModelContext
    ) throws {
        context.delete(waypoint)

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
