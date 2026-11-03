import Foundation
import SwiftData
import CoreLocation

@Model
final class Waypoint {
    @Attribute(.unique) var id: UUID

    var name: String
    var latitude: Double
    var longitude: Double

    var createdAt: Date
    var locationTimestamp: Date
    var horizontalAccuracy: Double

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        createdAt: Date = .now,
        locationTimestamp: Date,
        horizontalAccuracy: Double
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.locationTimestamp = locationTimestamp
        self.horizontalAccuracy = horizontalAccuracy
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
