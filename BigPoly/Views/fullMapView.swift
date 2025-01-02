import SwiftUI
import MapKit
import HealthKit

struct FullMapView: View {
   let workout: HKWorkout
   @ObservedObject var polyViewModel: PolyViewModel
   @State private var routeCoordinates: [CLLocationCoordinate2D] = []
   @State private var cityName: String = "Fetching..."
   @State private var workoutDate: Date = Date()
   @State private var distance: Double = 0.0

   var body: some View {
	  VStack {
		 if !routeCoordinates.isEmpty {
			GradientMapView(coordinates: routeCoordinates)
			   .onAppear {
				  // Optionally set region or further logic
			   }
		 } else {
			Text("Loading route...")
			   .foregroundColor(.gray)
		 }
	  }
	  .onAppear {
		 Task {
			if let fetchedCoordinates = await polyViewModel.fetchDetailedRouteData(for: workout) {
			   routeCoordinates = fetchedCoordinates
			}
			if let fetchedCity = await polyViewModel.fetchCityName(for: workout) {
			   cityName = fetchedCity
			}
			distance = await polyViewModel.fetchDistance(for: workout)
			workoutDate = workout.startDate
		 }
	  }
	  .safeAreaInset(edge: .top) {
		 WorkoutMetricsView(cityName: cityName,
							workoutDate: workoutDate,
							distance: distance)
	  }
	  .navigationTitle("Workout Map")
	  .navigationBarTitleDisplayMode(.inline)
   }
}
