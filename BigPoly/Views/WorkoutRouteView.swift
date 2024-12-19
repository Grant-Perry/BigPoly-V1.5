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

   var body: some View {
	  VStack(alignment: .leading, spacing: 0) {
		 Text(workout.startDate.formatted(as: "MMM d, yy"))
			.font(.system(size: 18))
			.foregroundColor(.white)
			.padding(.trailing, 26)
			.frame(maxWidth: .infinity, alignment: .trailing)
			.offset(y: -10)

		 Text(cityName)
			.font(.system(size: 25)).bold()
			.foregroundColor(.white)
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.leading)

		 VStack(alignment: .leading, spacing: 5) {
			// Distance
			Text("Distance: \(String(format: "%.2f", distance)) mi")
			   .font(.system(size: 18).bold())
			   .foregroundColor(.secondary)
			   .frame(maxWidth: .infinity, alignment: .trailing)
			   .padding(.trailing, 30)

			// Total Time
			Text("Time: \(formattedTotalTime)")
			   .font(.system(size: 16))
			   .foregroundColor(.secondary)
			   .frame(maxWidth: .infinity, alignment: .trailing)
			   .padding(.trailing, 30)

			// Average Pace
			HStack {
			   Spacer() // Push content to the trailing side
			   (Text("Pace: \(averagePace) ")
				  .font(.system(size: 16))
				  .foregroundColor(.secondary) +
 				Text("min/mi")
				  .font(.system(size: 8))
				  .foregroundColor(.secondary))
			}
			.frame(maxWidth: .infinity, alignment: .trailing) // Ensure the HStack aligns content to trailing
			.padding(.trailing, 30)

//			HStack {
//			   Text("miles")
//				  .font(.system(size: 8))
//				  .frame(maxWidth: .infinity, alignment: .trailing)
//				  .padding(.trailing, 30)
//			}
		 }
		 .foregroundColor(.white)
		 .padding(.leading, 20)
		 .frame(maxWidth: .infinity, alignment: .leading)

	  }
	  .frame(width: UIScreen.main.bounds.width * 0.85, height: 150)
	  .background(
		 LinearGradient(colors: [.gpDeltaPurple, .clear], startPoint: .top, endPoint: .bottom)
	  )
	  .cornerRadius(10)
	  // Existing overlay and shadow code if any
	  .onAppear {
		 Task {
			if let fetchedCity = await polyViewModel.fetchCityName(for: workout) {
			   cityName = fetchedCity
			} else {
			   cityName = "Unknown City"
			}
			distance = await polyViewModel.fetchDistance(for: workout) ?? 0

			// Compute total time from workout.duration (in seconds)
			totalTime = workout.duration
			formattedTotalTime = formatDuration(totalTime)

			// Compute average pace: totalTime (min) / distance (miles)
			// average pace in min/mi
			let totalMinutes = totalTime / 60.0
			if distance > 0 {
			   let pace = totalMinutes / distance
			   averagePace = formatPace(pace)
			} else {
			   averagePace = "--:--"
			}
		 }
	  }
	  .preferredColorScheme(.dark)
   }

   // Helper to format duration as "HH:MM:SS" or "MM:SS"
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

   // Helper to format pace (which is given in minutes per mile)
   // pace is a Double representing minutes per mile
   func formatPace(_ pace: Double) -> String {
	  let wholeMinutes = Int(pace)
	  let fractionalPart = pace - Double(wholeMinutes)
	  let seconds = Int(fractionalPart * 60.0)
	  return String(format: "%d:%02d", wholeMinutes, seconds)
   }
}
