import SwiftUI
import CoreLocation

struct MapScreen: View {
    
    @StateObject private var locationService = LocationService()
    @State private var waypoints: [Waypoint] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            MapView()
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                LocationCard()
                
                Button {
                    saveWaypoint(locationService: locationService, waypoints: &waypoints)
                } label: {
                    Label("Save Waypoint", systemImage: "mappin.and.ellipse")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.thinMaterial, in: .rect(cornerRadius: 16))
                }
                .buttonStyle(.glass)
            }
            .padding()
        }
        .onAppear {
            locationService.start()
        }
    }
}
