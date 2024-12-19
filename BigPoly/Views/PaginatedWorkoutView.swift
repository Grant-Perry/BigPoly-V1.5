import SwiftUI
import HealthKit
import Observation

struct PaginatedWorkoutsView: View {
   @ObservedObject var polyViewModel: PolyViewModel
   @State private var currentPage = 0

   var body: some View {
	  NavigationView {
		 VStack {
			NavigationLink("Sort & Filter", destination: SortingFilteringView(polyViewModel: polyViewModel))

			List(polyViewModel.workouts, id: \.uuid) { workout in
			   NavigationLink(destination: FullMapView(workout: workout, polyViewModel: polyViewModel)) {
				  WorkoutRouteView(workout: workout, polyViewModel: polyViewModel)
			   }
			}

			if polyViewModel.isLoading {
			   ProgressView()
			}

			Button("Load More") {
			   currentPage += 1
			   polyViewModel.loadWorkouts(page: currentPage)
			}
		 }
		 .navigationTitle("Workouts")
	  }
	  .onAppear {
		 polyViewModel.loadWorkouts(page: currentPage)
	  }
   }
   
}

