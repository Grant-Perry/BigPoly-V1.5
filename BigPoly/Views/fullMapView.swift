import SwiftUI
import MapKit
import HealthKit

struct FullMapView: View {
   let workout: HKWorkout
   @ObservedObject var polyViewModel: PolyViewModel
   
   @State private var routeCoordinates: [CLLocationCoordinate2D] = []
   @State private var metricMeta: MetricMeta? = nil
   @State private var convertedWorkout: WorkoutCore? = nil
   @State private var isError: Bool = false
   @State private var errorMessage: String = ""
   @State private var mapType: MKMapType = .standard
   
   var body: some View {
	  VStack {
		 Picker("Map Type", selection: $mapType) {
			Text("Standard").tag(MKMapType.standard)
			Text("Satellite").tag(MKMapType.satellite)
		 }
		 .pickerStyle(SegmentedPickerStyle())
		 .padding()
		 
		 if isError {
			Text(errorMessage)
			   .font(.system(size: 17))
			   .foregroundColor(.red)
			   .frame(maxWidth: .infinity, alignment: .center)
		 } else {
			if !routeCoordinates.isEmpty {
			   GradientMapView(coordinates: routeCoordinates, mapType: $mapType)
			} else {
			   Text("No route data available.")
				  .foregroundColor(.gray)
			}
		 }
	  }
	  .onAppear {
		 Task {
			do {
			   WorkoutCore.shared.update(from: workout)
			   convertedWorkout = WorkoutCore.shared
			   
			   if let fetchedRoute = await polyViewModel.fetchDetailedRouteData(for: workout) {
				  routeCoordinates = fetchedRoute
			   } else {
				  throw NSError(domain: "com.BigPoly", code: 404, userInfo: [NSLocalizedDescriptionKey: "No route data found."])
			   }
			   
			   let cityName = await polyViewModel.fetchCityName(for: workout) ?? "Unknown City"
			   let totalTime = formatDuration(polyViewModel.fetchDuration(for: workout))
			   let averageSpeed = polyViewModel.fetchAverageSpeed(for: workout)
			   
			   var weatherTemp: String? = nil
			   var weatherSymbol: String? = nil
			   if let (temp, symbol) = await polyViewModel.fetchWeather(for: workout) {
				  weatherTemp = temp
				  weatherSymbol = symbol
			   }
			   
			   metricMeta = MetricMeta(
				  weatherTemp: weatherTemp,
				  weatherSymbol: weatherSymbol,
				  cityName: cityName,
				  totalTime: totalTime,
				  averageSpeed: averageSpeed
			   )
			} catch {
			   isError = true
			   errorMessage = error.localizedDescription
			   print("Error fetching data: \(error.localizedDescription)")
			}
		 }
	  }
	  .safeAreaInset(edge: .top) {
		 if let metricMeta = metricMeta, let workoutCore = convertedWorkout {
			WorkoutMetricsView(workout: workoutCore, metricMeta: metricMeta)
		 }
	  }
	  .navigationTitle("Workout Map")
	  .navigationBarTitleDisplayMode(.inline)
   }
}

func formatDuration(_ duration: TimeInterval) -> String {
   let hours = Int(duration) / 3600
   let minutes = (Int(duration) % 3600) / 60
   let seconds = Int(duration) % 60
   
   if hours > 0 {
	  return String(format: "%d:%02d:%02d", hours, minutes, seconds)
   } else {
	  return String(format: "%02d:%02d", minutes, seconds)
   }
}
