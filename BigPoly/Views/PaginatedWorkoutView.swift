import SwiftUI
import HealthKit
import Observation

struct PaginatedWorkoutsView: View {
   @ObservedObject var polyViewModel: PolyViewModel
   @State private var currentPageIndex = 0

   var body: some View {
	  NavigationView {
		 VStack {
			NavigationLink("Sort & Filter") {
			   SortingFilteringView(polyViewModel: polyViewModel)
			}

			List(polyViewModel.workouts, id: \.uuid) { workoutItem in
			   NavigationLink(destination: FullMapView(workout: workoutItem, polyViewModel: polyViewModel)) {
				  WorkoutRouteView(workout: workoutItem, polyViewModel: polyViewModel)
			   }
			}

			if polyViewModel.isLoading {
			   ProgressView()
			}

			Button("Load More") {
			   currentPageIndex += 1
			   polyViewModel.loadWorkouts(page: currentPageIndex)
			}
		 }
		 .navigationTitle("Workouts")
	  }
	  .onAppear {
		 polyViewModel.loadWorkouts(page: currentPageIndex)
	  }
   }
}
