import SwiftUI
import HealthKit
import Observation

struct PaginatedWorkoutsView: View {
   @ObservedObject var polyViewModel: PolyViewModel
   @State private var currentPage = 0

   var body: some View {
	  NavigationView {
		 VStack(spacing: 0) {
			NavigationLink("Sort & Filter", destination: SortingFilteringView(polyViewModel: polyViewModel))

			List(polyViewModel.workouts, id: \.uuid) { workout in
			   NavigationLink(destination: FullMapView(workout: workout, polyViewModel: polyViewModel)) {
				  WorkoutRouteView(workout: workout, polyViewModel: polyViewModel)
			   }
			   .offset(y: -15)
			}

			if polyViewModel.isLoading {
			   ProgressView()
			}

			Text("\(AppConstants.appName) - ver: \(AppConstants.getVersion())")
			   .font(.system(size: 14))
			   .foregroundColor(.white)
			   .frame(maxWidth: .infinity, alignment: .center)
			   .padding(.bottom, 8)
		 }
		 .navigationTitle("\(AppConstants.title)")
	  }
	  .onAppear {
		 currentPage = 0
		 polyViewModel.loadWorkouts(page: currentPage)
	  }
   }

}
