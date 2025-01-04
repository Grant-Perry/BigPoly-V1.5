import SwiftUI

struct AppConstants {
   static let appName = "BigPoly"
   static let title = "Gp. Workouts"

   static func getVersion() -> String {
	  return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
   }
}
