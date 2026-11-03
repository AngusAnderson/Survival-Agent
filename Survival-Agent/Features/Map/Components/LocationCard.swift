import SwiftUI

struct LocationCard: View {
    
    @StateObject private var locationService = LocationService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let location = locationService.location {
                Text("Current position")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("\(location.coordinate.latitude, specifier: "%.5f"), \(location.coordinate.longitude, specifier: "%.5f")")
                    .font(.headline.monospaced())
                
                if let heading = locationService.heading {
                    Text("Heading: \(heading.trueHeading, specifier: "%.0f")°")
                        .font(.subheadline)
                }
            } else {
                Text("Waiting for GPS signal...")
                    .font(.headline)
            }
            
            if let error = locationService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
    }
}
