import SwiftUI
import HealthKit

struct WorkoutRouteView: View {
   let workout: HKWorkout
   @ObservedObject var polyViewModel: PolyViewModel

   @State private var cityNameText: String = "Loading..."
   @State private var workoutDistanceMiles: Double = 0.0
   @State private var totalDurationSeconds: TimeInterval = 0.0
   @State private var formattedTotalTime: String = "00:00"
   @State private var averagePaceString: String = "--:--"
   @State private var firstWaypointTime: String = ""

   var body: some View {
	  ZStack {
		 VStack(spacing: 0) {
			// TOP SECTION
			ZStack {
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
				  // City
				  Text(cityNameText)
					 .font(.title3).bold()
					 .frame(maxWidth: .infinity)
					 .lineLimit(1)
					 .minimumScaleFactor(0.65)
					 .scaledToFit()
					 .foregroundColor(.white)

				  Spacer()

				  VStack(alignment: .trailing, spacing: 4) {
					 Text(workout.startDate.formatted(as: "MMM d, yy"))
						.font(.system(size: 14))
						.foregroundColor(.white.opacity(0.8))

					 if !firstWaypointTime.isEmpty {
						Text(firstWaypointTime)
						   .font(.system(size: 10))
						   .foregroundColor(.white.opacity(0.6))
					 }
				  }
			   }
			   .padding()
			}
			.frame(height: 30)

			// BOTTOM SECTION
			ZStack {
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
						Text("\(workoutDistanceMiles, specifier: "%.2f") mi")
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
						   Text(averagePaceString)
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
	  .onAppear {
		 Task {
			// City
			if let foundCity = await polyViewModel.fetchCityName(for: workout) {
			   cityNameText = foundCity
			} else {
			   cityNameText = "Unknown City"
			}

			// Distance
			workoutDistanceMiles = await polyViewModel.fetchDistance(for: workout)

			// Duration
			totalDurationSeconds = workout.duration
			formattedTotalTime = formatDuration(totalDurationSeconds)

			// Pace
			let totalMinutes = totalDurationSeconds / 60.0
			averagePaceString = (workoutDistanceMiles > 0)
			? formatPace(totalMinutes / workoutDistanceMiles)
			: "--:--"

			// Waypoint time
			if let routeArray = await polyViewModel.getWorkoutRoute(workout: workout),
			   let firstRoute = routeArray.first {
			   let locationList = await polyViewModel.getCLocationDataForRoute(routeToExtract: firstRoute)
			   if let firstLocationData = locationList.first {
				  firstWaypointTime = formatTimeOfDay(dateObject: firstLocationData.timestamp)
			   }
			}
		 }
	  }
	  .preferredColorScheme(.dark)
   }

   // MARK: - Helper Methods
   private func formatDuration(_ durationSeconds: TimeInterval) -> String {
	  let hourCount = Int(durationSeconds) / 3600
	  let minuteCount = (Int(durationSeconds) % 3600) / 60
	  let secondCount = Int(durationSeconds) % 60

	  if hourCount > 0 {
		 return String(format: "%d:%02d:%02d", hourCount, minuteCount, secondCount)
	  } else {
		 return String(format: "%02d:%02d", minuteCount, secondCount)
	  }
   }

   private func formatPace(_ paceMinutes: Double) -> String {
	  let wholeMinutes = Int(paceMinutes)
	  let fractionalPart = paceMinutes - Double(wholeMinutes)
	  let secondCount = Int(fractionalPart * 60.0)
	  return String(format: "%d:%02d", wholeMinutes, secondCount)
   }

   private func formatTimeOfDay(dateObject: Date) -> String {
	  let dateFormatterObject = DateFormatter()
	  dateFormatterObject.dateFormat = "h:mm a"
	  return dateFormatterObject.string(from: dateObject)
   }
}
