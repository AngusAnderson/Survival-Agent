import SwiftUI
import MapLibre
import CoreLocation

struct MapFocusRequest {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

final class WaypointAnnotation: MLNPointAnnotation {
    var waypointID: UUID?
}

struct MapView: UIViewRepresentable {
    var waypoints: [Waypoint]
    var focusRequest: MapFocusRequest?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> MLNMapView {
        let mapView = MLNMapView(frame: .zero)

        mapView.styleURL = URL(
            string: "https://demotiles.maplibre.org/style.json"
        )

        mapView.showsUserLocation = true
        mapView.showsUserHeadingIndicator = true
        mapView.userTrackingMode = .followWithHeading

        mapView.delegate = context.coordinator

        return mapView
    }

    func updateUIView(
        _ mapView: MLNMapView,
        context: Context
    ) {
        context.coordinator.updateAnnotations(
            on: mapView,
            waypoints: waypoints
        )

        guard let request = focusRequest,
              context.coordinator.lastFocusID != request.id else {
            return
        }

        context.coordinator.lastFocusID = request.id

        mapView.setUserTrackingMode(.none, animated: false)

        mapView.setCenter(
            request.coordinate,
            zoomLevel: 15,
            animated: true
        )
    }

    final class Coordinator: NSObject, MLNMapViewDelegate {
        var lastFocusID: UUID?

        private var annotationsByID: [UUID: WaypointAnnotation] = [:]

        func updateAnnotations(
            on mapView: MLNMapView,
            waypoints: [Waypoint]
        ) {
            let currentIDs = Set(waypoints.map(\.id))

            let removedIDs = annotationsByID.keys.filter {
                !currentIDs.contains($0)
            }

            for id in removedIDs {
                if let annotation = annotationsByID.removeValue(
                    forKey: id
                ) {
                    mapView.removeAnnotation(annotation)
                }
            }

            for waypoint in waypoints {
                if let annotation = annotationsByID[waypoint.id] {
                    annotation.title = waypoint.name

                    if annotation.coordinate.latitude != waypoint.latitude ||
                        annotation.coordinate.longitude != waypoint.longitude {
                        annotation.coordinate = waypoint.coordinate
                    }
                } else {
                    let annotation = WaypointAnnotation()

                    annotation.waypointID = waypoint.id
                    annotation.title = waypoint.name
                    annotation.coordinate = waypoint.coordinate

                    annotationsByID[waypoint.id] = annotation

                    mapView.addAnnotation(annotation)
                }
            }
        }

        func mapView(
            _ mapView: MLNMapView,
            annotationCanShowCallout annotation: MLNAnnotation
        ) -> Bool {
            annotation is WaypointAnnotation
        }
    }
}
