import CoreLocation

func saveWaypoint(locationService: LocationService, waypoints: inout [Waypoint]) {
    guard let location = locationService.location else { return }
    
    let waypoint = Waypoint(
        name: "Waypoint \(waypoints.count + 1)",
        latitude: location.coordinate.latitude,
        longitude: location.coordinate.longitude
    )
    
    waypoints.append(waypoint)
}
