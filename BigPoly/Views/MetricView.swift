import SwiftUI

struct MetricsView: View {
   var workout: WorkoutCore
   var metricMeta: MetricMeta

   var body: some View {
	  ScrollView {
		 VStack(alignment: .leading, spacing: 20) {
			Text("Workout Metrics")
			   .font(.largeTitle)
			   .fontWeight(.bold)
			   .padding(.bottom, 10)

			HStack {
			   if let weatherSymbol = metricMeta.weatherSymbol {
				  Image(systemName: weatherSymbol)
					 .resizable()
					 .scaledToFit()
					 .frame(height: 150)
					 .cornerRadius(20)
			   }

			   VStack(alignment: .leading) {
				  Text(metricMeta.cityName)
					 .font(.title2)
					 .fontWeight(.semibold)

				  if let wTemp = metricMeta.weatherTemp {
					 Text("Temperature: \(wTemp)°F")
						.font(.headline)
				  }

				  if let speed = metricMeta.averageSpeed {
					 Text("Avg Speed: \(String(format: "%.2f", speed)) mph")
						.font(.headline)
				  }

				  Text("Total Time: \(metricMeta.totalTime)")
					 .font(.headline)
			   }
			}
			.padding()
			.background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.2)))

			VStack {
//			   MetricRow(title: "Distance", value: "\(workout.distance, specifier: "%.2f") mi")
			   MetricRow(title: "Distance", value: String(format: "%.2f mi", workout.distance))

//			   MetricRow(title: "Calories Burned", value: "\(workout.caloriesBurned) kcal")
//			   MetricRow(title: "Heart Rate", value: "\(workout.averageHeartRate) bpm")
//			   MetricRow(title: "Elevation Gain", value: "\(workout.elevationGain) ft")
			}
		 }
		 .padding()
	  }
	  .navigationTitle("Metrics")
   }
}

struct MetricRow: View {
   var title: String
   var value: String

   var body: some View {
	  HStack {
		 Text(title)
			.font(.title3)
			.fontWeight(.medium)
		 Spacer()
		 Text(value)
			.font(.headline)
			.fontWeight(.bold)
	  }
	  .padding()
	  .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue.opacity(0.2)))
   }
}
