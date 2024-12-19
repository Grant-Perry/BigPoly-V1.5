import SwiftUI

@main
struct BigPolyApp: App {
   @StateObject private var polyViewModel = PolyViewModel()
   var body: some Scene {
	  WindowGroup {
		 PaginatedWorkoutsView(polyViewModel: polyViewModel)
	  }
   }
}

