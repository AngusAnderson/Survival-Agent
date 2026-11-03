import SwiftUI
import SwiftData

struct WaypointListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Waypoint.createdAt, order: .reverse)
    private var waypoints: [Waypoint]

    @State private var pendingDeletion: Waypoint?
    @State private var showingDeleteConfirmation = false

    @State private var showingError = false
    @State private var errorMessage = ""

    private let onSelect: (Waypoint) -> Void

    init(onSelect: @escaping (Waypoint) -> Void) {
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationStack {
            Group {
                if waypoints.isEmpty {
                    ContentUnavailableView(
                        "No saved waypoints",
                        systemImage: "mappin.slash",
                        description: Text(
                            "Save your current position from the map."
                        )
                    )
                } else {
                    List {
                        ForEach(waypoints) { waypoint in
                            Button {
                                onSelect(waypoint)
                                dismiss()
                            } label: {
                                waypointRow(waypoint)
                            }
                            .buttonStyle(.plain)
                            .swipeActions {
                                Button(role: .destructive) {
                                    pendingDeletion = waypoint
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Waypoints")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Delete this waypoint?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete waypoint", role: .destructive) {
                    deletePendingWaypoint()
                }

                Button("Cancel", role: .cancel) {
                    pendingDeletion = nil
                }
            } message: {
                Text(pendingDeletion?.name ?? "")
            }
            .alert(
                "Could not delete waypoint",
                isPresented: $showingError
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func waypointRow(_ waypoint: Waypoint) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(
                waypoint.name,
                systemImage: "mappin.circle.fill"
            )
            .font(.headline)

            Text(
                String(
                    format: "%.5f, %.5f",
                    waypoint.latitude,
                    waypoint.longitude
                )
            )
            .font(.caption.monospaced())
            .foregroundStyle(.secondary)

            Text(
                "Reported accuracy: ±\(Int(waypoint.horizontalAccuracy)) m"
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(
                waypoint.createdAt,
                format: .dateTime.day().month().hour().minute()
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func deletePendingWaypoint() {
        guard let waypoint = pendingDeletion else {
            return
        }

        do {
            try WaypointStore.delete(
                waypoint,
                context: modelContext
            )
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }

        pendingDeletion = nil
    }
}
