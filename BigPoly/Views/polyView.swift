import SwiftUI

struct PolyView: View {
   @ObservedObject var polyViewModel: PolyViewModel
   @State private var myMaxWorkoutCount = 150

   var body: some View {
	  NavigationView {
		 if polyViewModel.isLoading {
			LoadingView()
		 } else {
			List(polyViewModel.workouts, id: \.uuid) { workoutItem in
			   NavigationLink(destination: FullMapView(workout: workoutItem, polyViewModel: polyViewModel)) {
				  WorkoutRouteView(workout: workoutItem, polyViewModel: polyViewModel)
			   }
			}
			.navigationTitle("Workouts")
		 }
	  }
	  .onAppear {
		 polyViewModel.maxWorkoutCount = myMaxWorkoutCount
		 polyViewModel.loadWorkouts(page: 0)
	  }
   }
}
