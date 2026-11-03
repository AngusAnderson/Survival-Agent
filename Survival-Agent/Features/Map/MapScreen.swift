import SwiftUI
import SwiftData
import CoreLocation

struct MapScreen: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Waypoint.createdAt, order: .reverse)
    private var waypoints: [Waypoint]

    @StateObject private var locationService = LocationService()

    @State private var focusRequest: MapFocusRequest?
    @State private var showingWaypoints = false

    @State private var showingNamePrompt = false
    @State private var waypointName = ""

    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            MapView(
                waypoints: waypoints,
                focusRequest: focusRequest
            )
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 12) {
                locationCard

                HStack(spacing: 12) {
                    Button {
                        waypointName = ""
                        showingNamePrompt = true
                    } label: {
                        Label(
                            "Save waypoint",
                            systemImage: "mappin.and.ellipse"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSaveLocation)

                    Button {
                        showingWaypoints = true
                    } label: {
                        Label(
                            "Waypoints (\(waypoints.count))",
                            systemImage: "list.bullet"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(
                    .regularMaterial,
                    in: RoundedRectangle(cornerRadius: 16)
                )
            }
            .padding()
        }
        .onAppear {
            locationService.start()
        }
        .sheet(isPresented: $showingWaypoints) {
            WaypointListView { waypoint in
                focusRequest = MapFocusRequest(
                    coordinate: waypoint.coordinate
                )
            }
        }
        .alert("Save waypoint", isPresented: $showingNamePrompt) {
            TextField("Waypoint name", text: $waypointName)

            Button("Cancel", role: .cancel) {}

            Button("Save") {
                saveCurrentLocation()
            }
        } message: {
            Text("Save your current position on this device.")
        }
        .alert("Could not save waypoint", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private var canSaveLocation: Bool {
        guard let location = locationService.location else {
            return false
        }

        return WaypointStore.isUsable(location)
    }

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            switch locationService.authorizationStatus {
            case .denied:
                Text("Location access denied")
                    .font(.headline)

                Text("Enable location access in Settings to save your position.")
                    .font(.caption)

            case .restricted:
                Text("Location access is restricted")
                    .font(.headline)

            default:
                if let location = locationService.location {
                    Text("Current position")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(
                        String(
                            format: "%.5f, %.5f",
                            location.coordinate.latitude,
                            location.coordinate.longitude
                        )
                    )
                    .font(.headline.monospaced())

                    if location.horizontalAccuracy >= 0 {
                        Text(
                            "Reported accuracy: ±\(Int(location.horizontalAccuracy)) m"
                        )
                        .font(.caption)
                    }

                    if !canSaveLocation {
                        Text("Waiting for a fresh, usable location…")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                } else {
                    Text("Waiting for location…")
                        .font(.headline)
                }
            }

            if let error = locationService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    private func saveCurrentLocation() {
        guard let location = locationService.location else {
            errorMessage = "Your current location is not available."
            showingError = true
            return
        }

        do {
            try WaypointStore.save(
                name: waypointName,
                location: location,
                context: modelContext
            )
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
