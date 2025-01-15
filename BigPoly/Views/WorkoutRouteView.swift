import SwiftUI
import HealthKit

struct WorkoutRouteView: View {
   let workout: HKWorkout
   @ObservedObject var polyViewModel: PolyViewModel

   @State private var cityName: String = "Loading..."
   @State private var distance: Double = 0.0
   @State private var totalTime: TimeInterval = 0.0
   @State private var formattedTotalTime: String = "00:00"
   @State private var averageSpeed: Double? = nil
   @State private var weatherTemp: String? = nil
   @State private var weatherSymbol: String? = nil
   @State private var routeStartDate: Date? = nil

   /// Date formatter
   private var dateFormatter: DateFormatter {
	  let df = DateFormatter()
	  df.dateStyle = .medium
	  return df
   }

   /// Time formatter
   private var timeFormatter: DateFormatter {
	  let df = DateFormatter()
	  df.timeStyle = .short
	  return df
   }

   var body: some View {
	  VStack(spacing: 8) {
		 /// Top section with city and date
		 HStack(alignment: .top) {
			/// Left side - City and Weather
			VStack(alignment: .leading, spacing: 4) {
			   Text(cityName)
				  .font(.system(size: 24, weight: .bold))
				  .foregroundColor(.white)
				  .frame(maxWidth: .infinity, alignment: .leading)

			   /// Weather Info if available
			   if let wTemp = weatherTemp, let wSymbol = weatherSymbol {
				  HStack(spacing: 6) {
					 Image(systemName: wSymbol)
						.foregroundColor(.white.opacity(0.9))

					 Text("\(wTemp)°")
						.font(.system(size: 15))
						.foregroundColor(.white.opacity(0.9))

					 /// Show embedded-weather icon
					 Image(systemName: "face.dashed.fill")
						.font(.system(size: 7))
						.foregroundColor(.gpGreen)
				  }
			   }
			}

			Spacer()

			/// Right side - Date and Time
			if let routeDate = routeStartDate {
			   VStack(alignment: .trailing, spacing: 4) {
				  Text(routeDate, formatter: dateFormatter)
					 .font(.system(size: 17))
					 .foregroundColor(.white)

				  Text(routeDate, formatter: timeFormatter)
					 .font(.system(size: 15))
					 .foregroundColor(.white.opacity(0.8))
			   }
			}
		 }

		 /// Bottom section with Duration, Pace, and Distance
		 HStack(alignment: .top) {
			Spacer()

			/// Duration Column
			VStack(alignment: .trailing, spacing: 4) {
			   Text("Duration")
				  .font(.system(size: 15))
				  .foregroundColor(.white)
			   Text(formattedTotalTime)
				  .font(.system(size: 17))
				  .foregroundColor(.white)
			}

			Spacer()
			   .frame(width: 40)

			/// Pace Column - always showing min/mi
			VStack(alignment: .trailing, spacing: 4) {
			   Text("Pace")
				  .font(.system(size: 15))
				  .foregroundColor(.white)
			   Text(formatPaceMinMi())
				  .font(.system(size: 17))
				  .foregroundColor(.white)
			}

			Spacer()
			   .frame(width: 40)

			/// Distance Column
			VStack(alignment: .trailing, spacing: 4) {
			   Text("Distance")
				  .font(.system(size: 15))
				  .foregroundColor(.white)
			   Text(String(format: "%.2f mi", distance))
				  .font(.system(size: 17, weight: .bold))
				  .foregroundColor(.white)
			}
		 }
		 .padding(.vertical, 8)
		 .padding(.horizontal, 12)
		 .background(
			LinearGradient(colors: [.gpWhite, .secondary],
						   startPoint: .top,
						   endPoint: .bottom)
			.opacity(0.3)
		 )
		 .cornerRadius(8)
	  }
	  .padding(.horizontal, 16)
	  .padding(.vertical, 12)
	  .frame(width: UIScreen.main.bounds.width * 0.85)
	  .background(
		 LinearGradient(colors: [.gpDeltaPurple, .clear],
						startPoint: .top,
						endPoint: .bottom)
	  )
	  .cornerRadius(12)
	  .onAppear {
		 Task {
			cityName = await polyViewModel.fetchCityName(for: workout) ?? "Unknown City"
			distance = await polyViewModel.fetchDistance(for: workout) ?? 0
			totalTime = polyViewModel.fetchDuration(for: workout)
			formattedTotalTime = formatDuration(totalTime)
			averageSpeed = polyViewModel.fetchAverageSpeed(for: workout)
			if let (temp, symbol) = await polyViewModel.fetchWeather(for: workout) {
			   weatherTemp = temp
			   weatherSymbol = symbol
			}
			if let allLocs = await polyViewModel.fetchFullLocationData(for: workout),
			   let first = allLocs.first {
			   routeStartDate = first.timestamp
			}
		 }
	  }
	  .preferredColorScheme(.dark)
   }

   /// Helper to format duration as "HH:MM:SS" or "MM:SS"
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

   /// Helper function for min/mi pace
   private func formatPaceMinMi() -> String {
	  guard distance > 0, totalTime > 0 else { return "--" }

	  let minutes = totalTime / 60.0
	  let pace = minutes / distance
	  let wholeMinutes = Int(pace)
	  let seconds = Int((pace - Double(wholeMinutes)) * 60)
	  return String(format: "%d:%02d", wholeMinutes, seconds)
   }
}
