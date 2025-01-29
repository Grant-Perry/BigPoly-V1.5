import SwiftUI
import CoreLocation

struct IdentifiableCoordinate: Identifiable {
   let id = UUID()
   let coordinate: CLLocationCoordinate2D
}
