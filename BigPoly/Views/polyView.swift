import SwiftUI
import HealthKit

struct PolyView: View {
   @ObservedObject var polyViewModel: PolyViewModel
   @State private var workoutLimit = 150

   var body: some View {
	  NavigationView {
		 if polyViewModel.isLoading {
			LoadingView()
		 } else {
			List(polyViewModel.workouts, id: \.uuid) { workout in
			   NavigationLink(destination: FullMapView(workout: workout, polyViewModel: polyViewModel)) {
				  WorkoutRouteView(workout: workout, polyViewModel: polyViewModel)
			   }
			}
			.navigationTitle("Workouts")
		 }
	  }
	  .onAppear {
		 polyViewModel.limit = workoutLimit
		 polyViewModel.loadWorkouts(page: 0)
	  }
   }
}
