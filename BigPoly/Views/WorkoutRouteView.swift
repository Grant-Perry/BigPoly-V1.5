import SwiftUI
import HealthKit

struct WorkoutRouteView: View {
   let workout: HKWorkout
   @ObservedObject var polyViewModel: PolyViewModel
   @State private var metricMeta: MetricMeta? = nil
   
   @State private var cityName: String = "Loading..."
   @State private var distance: Double = 0.0
   @State private var totalTime: TimeInterval = 0.0
   @State private var formattedTotalTime: String = "00:00"
   @State private var averageSpeed: Double? = nil
   @State private var weatherTemp: String? = nil
   @State private var weatherSymbol: String? = nil
   @State private var routeStartDate: Date? = nil
   @State private var isError: Bool = false
   @State private var errorMessage: String = ""
   
   private var dateFormatter: DateFormatter {
	  let df = DateFormatter()
	  df.dateStyle = .medium
	  return df
   }
   
   private var timeFormatter: DateFormatter {
	  let df = DateFormatter()
	  df.timeStyle = .short
	  return df
   }
   
   var body: some View {
	  VStack(spacing: 8) {
		 if isError {
			Text(errorMessage)
			   .font(.system(size: 17))
			   .foregroundColor(.red)
			   .frame(maxWidth: .infinity, alignment: .center)
		 } else {
			// Main content with workout details
			HStack(alignment: .top) {
			   VStack(alignment: .leading, spacing: 4) {
				  Text(cityName)
					 .font(.system(size: 24, weight: .bold))
					 .foregroundColor(.white)
					 .frame(maxWidth: .infinity, alignment: .leading)
				  
				  if let wTemp = weatherTemp, let wSymbol = weatherSymbol {
					 HStack(spacing: 6) {
						Image(systemName: wSymbol)
						   .foregroundColor(.white.opacity(0.9))
						Text("\(wTemp)°")
						   .font(.system(size: 15))
						   .foregroundColor(.white.opacity(0.9))
					 }
				  }
			   }
			   
			   Spacer()
			   
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
			
			HStack(alignment: .top) {
			   Spacer()
			   
			   VStack(alignment: .trailing, spacing: 4) {
				  Text("Duration")
					 .font(.system(size: 15))
					 .foregroundColor(.white)
				  Text(formattedTotalTime)
					 .font(.system(size: 17))
					 .foregroundColor(.white)
			   }
			   
			   Spacer(minLength: 40)
			   
			   VStack(alignment: .trailing, spacing: 4) {
				  Text("Pace")
					 .font(.system(size: 15))
					 .foregroundColor(.white)
				  Text(formatPaceMinMi())
					 .font(.system(size: 17))
					 .foregroundColor(.white)
			   }
			   
			   Spacer(minLength: 40)
			   
			   VStack(alignment: .trailing, spacing: 4) {
				  Text("Distance")
					 .font(.system(size: 15))
					 .foregroundColor(.white)
				  Text(String(format: "%.2f mi", distance))
					 .font(.system(size: 17, weight: .bold))
					 .foregroundColor(.white)
			   }
			}
		 }
	  }
	  .padding()
	  .background(
		 LinearGradient(colors: [.black, .gray], startPoint: .top, endPoint: .bottom)
			.opacity(0.3)
	  )
	  .cornerRadius(12)
	  .task {
		 do {
			cityName = await polyViewModel.fetchCityName(for: workout) ?? "Unknown City"
			distance = await polyViewModel.fetchDistance(for: workout) ?? 0
			totalTime = polyViewModel.fetchDuration(for: workout)
			formattedTotalTime = formatDuration(totalTime)
			averageSpeed = polyViewModel.fetchAverageSpeed(for: workout)
			routeStartDate = workout.startDate
			
			if let (temp, symbol) = await polyViewModel.fetchWeather(for: workout) {
			   weatherTemp = temp
			   weatherSymbol = symbol
			}
			
			if distance == 0 && cityName == "Unknown City" {
			   throw NSError(domain: "com.BigPoly", code: 404, userInfo: [NSLocalizedDescriptionKey: "No workout data available"])
			}
		 } catch {
			isError = true
			errorMessage = "Failed to load workout data. Please try again."
			print("Error fetching data: \(error.localizedDescription)")
		 }
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
   
   func formatPaceMinMi() -> String {
	  guard distance > 0, totalTime > 0 else { return "--" }
	  let minutes = totalTime / 60.0
	  let pace = minutes / distance
	  let wholeMinutes = Int(pace)
	  let seconds = Int((pace - Double(wholeMinutes)) * 60)
	  return String(format: "%d:%02d", wholeMinutes, seconds)
   }
}
