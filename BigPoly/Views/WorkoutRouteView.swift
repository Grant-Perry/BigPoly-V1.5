import SwiftUI
import HealthKit

struct WorkoutRouteView: View {
   let workout: HKWorkout
   @ObservedObject var polyViewModel: PolyViewModel

   @State private var cityName: String = "Loading..."
   @State private var distance: Double = 0.0
   @State private var totalTime: TimeInterval = 0.0
   @State private var formattedTotalTime: String = "00:00"
   @State private var averagePace: String = "--:--"
   @State private var waypointTime: String = ""  // Time of day from the first waypoint

   var body: some View {
	  ZStack {
		 VStack(spacing: 0) {
			// TOP SECTION (City, Date, Time of Day)
			ZStack {
			   // Background gradient for top section
			   Rectangle()
				  .fill(
					 LinearGradient(
						colors: [.gpDeltaPurple.opacity(0.5), .clear],
						startPoint: .top,
						endPoint: .bottom
					 )
				  )
				  .cornerRadius(12, corners: [.topLeft, .topRight])

			   HStack {
				  // City Name on the left
				  Text(cityName)
					 .font(.title3).bold()
					 .frame(maxWidth: .infinity)
					 .lineLimit(1)
					 .minimumScaleFactor(0.65)
					 .scaledToFit()
					 .foregroundColor(.white)

				  Spacer()

				  // Date and (optional) time of day on the right
				  VStack(alignment: .trailing, spacing: 4) {
					 Text(workout.startDate.formatted(as: "MMM d, yy"))
						.font(.system(size: 14))
						.foregroundColor(.white.opacity(0.8))

					 // If we have a valid waypoint time, show it
					 if !waypointTime.isEmpty {
						Text(waypointTime)
						   .font(.system(size: 10))
						   .foregroundColor(.white.opacity(0.6))
					 }
				  }
			   }
			   .padding()
			}
			.frame(height: 30)

			// BOTTOM SECTION (Distance, Time, Pace)
			ZStack {
			   // Background gradient for bottom section
			   Rectangle()
				  .fill(
					 LinearGradient(
						colors: [.clear, .gpDeltaPurple.opacity(0.5)],
						startPoint: .top,
						endPoint: .bottom
					 )
				  )
				  .cornerRadius(12, corners: [.bottomLeft, .bottomRight])

			   VStack(spacing: 0) {

				  HStack {
					 // Distance
					 VStack(alignment: .leading, spacing: 2) {
						Text("Distance")
						   .font(.system(size: 12))
						   .foregroundColor(.white.opacity(0.7))
						Text("\(distance, specifier: "%.2f") mi")
						   .font(.system(size: 16).bold())
						   .foregroundColor(.white)
					 }

					 Spacer()

					 // Time
					 VStack(alignment: .leading, spacing: 2) {
						Text("Time")
						   .font(.system(size: 12))
						   .foregroundColor(.white.opacity(0.7))
						Text(formattedTotalTime)
						   .font(.system(size: 16).bold())
						   .foregroundColor(.white)
					 }

					 Spacer()

					 // Pace
					 VStack(alignment: .leading, spacing: 2) {
						Text("Pace")
						   .font(.system(size: 12))
						   .foregroundColor(.white.opacity(0.7))
						HStack(spacing: 2) {
						   Text(averagePace)
							  .font(.system(size: 16).bold())
							  .foregroundColor(.white)
						   Text("min/mi")
							  .font(.system(size: 10))
							  .foregroundColor(.white.opacity(0.7))
						}
					 }
				  }
				  .padding(.horizontal, 16)
				  .padding(.vertical, 12)
			   }
			}
			.frame(height: 55)
		 }
	  }
	  .frame(width: UIScreen.main.bounds.width * 0.85, height: 100)
//	  .border(Color.white.opacity(0.7), width: 1)
	  .onAppear {
		 Task {

			// Fetch city name
			if let fetchedCity = await polyViewModel.fetchCityName(for: workout) {
			   cityName = fetchedCity
			} else {
			   cityName = "Unknown City"
			}

			// Fetch distance
			distance = await polyViewModel.fetchDistance(for: workout) ?? 0

			// Compute total time from workout.duration (seconds)
			totalTime = workout.duration
			formattedTotalTime = formatDuration(totalTime)

			// Compute average pace (min/mile)
			let totalMinutes = totalTime / 60.0
			averagePace = distance > 0
			? formatPace(totalMinutes / distance)
			: "--:--"

			// If first waypoint is available, get its time of day
			if let routes = await polyViewModel.getWorkoutRoute(workout: workout),
			   let firstRoute = routes.first {
			   let locations = await polyViewModel.getCLocationDataForRoute(routeToExtract: firstRoute)
			   if let firstLoc = locations.first {
				  waypointTime = formatTimeOfDay(date: firstLoc.timestamp)
			   }
			}
		 }
	  }
	  .preferredColorScheme(.dark)
   }

   // MARK: - Helper Methods

   private func formatDuration(_ duration: TimeInterval) -> String {
	  let hours = Int(duration) / 3600
	  let minutes = (Int(duration) % 3600) / 60
	  let seconds = Int(duration) % 60

	  if hours > 0 {
		 return String(format: "%d:%02d:%02d", hours, minutes, seconds)
	  } else {
		 return String(format: "%02d:%02d", minutes, seconds)
	  }
   }

   private func formatPace(_ pace: Double) -> String {
	  let wholeMinutes = Int(pace)
	  let fractionalPart = pace - Double(wholeMinutes)
	  let seconds = Int(fractionalPart * 60.0)
	  return String(format: "%d:%02d", wholeMinutes, seconds)
   }

   private func formatTimeOfDay(date: Date) -> String {
	  let formatter = DateFormatter()
	  formatter.dateFormat = "h:mm a" // e.g. "7:42 AM"
	  return formatter.string(from: date)
   }
}
