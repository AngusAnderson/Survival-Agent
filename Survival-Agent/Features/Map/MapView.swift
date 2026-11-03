import SwiftUI
import MapLibre

struct MapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MLNMapView {
        let mapView = MLNMapView(frame: .zero)

        mapView.styleURL = URL(
            string: "https://demotiles.maplibre.org/style.json"
        )

        mapView.showsUserLocation = true
        mapView.showsUserHeadingIndicator = true
        mapView.userTrackingMode = .followWithHeading

        return mapView
    }

    func updateUIView(_ mapView: MLNMapView, context: Context) {}
}
