import SwiftUI
import HealthKit

struct MetricsView: View {
   let workout: HKWorkout

   var body: some View {
	  VStack(spacing: 20) {
		 Text("Workout Metrics")
			.font(.largeTitle.bold())
			.foregroundColor(.primary)
			.padding(.top)

		 HStack {
			VStack(alignment: .leading, spacing: 8) {
			   Text("Distance")
				  .font(.title2.weight(.medium))
				  .foregroundColor(.secondary)
			   Text(formatDistance(workout.totalDistance))
				  .font(.system(size: 40, weight: .bold, design: .rounded))
				  .foregroundColor(.blue)
			}
			Spacer()
			VStack(alignment: .trailing, spacing: 8) {
			   Text("Duration")
				  .font(.title2.weight(.medium))
				  .foregroundColor(.secondary)
			   Text(formatDuration(workout.duration))
				  .font(.system(size: 40, weight: .bold, design: .rounded))
				  .foregroundColor(.purple)
			}
		 }
		 .padding(.horizontal)

		 HStack {
			VStack(alignment: .leading, spacing: 8) {
			   Text("Calories Burned")
				  .font(.title2.weight(.medium))
				  .foregroundColor(.secondary)
			   Text(formatCalories(workout.totalEnergyBurned))
				  .font(.system(size: 40, weight: .bold, design: .rounded))
				  .foregroundColor(.orange)
			}
			Spacer()
			VStack(alignment: .trailing, spacing: 8) {
			   Text("Avg Heart Rate")
				  .font(.title2.weight(.medium))
				  .foregroundColor(.secondary)
			   Text(formatHeartRate(workout))
				  .font(.system(size: 40, weight: .bold, design: .rounded))
				  .foregroundColor(.red)
			}
		 }
		 .padding(.horizontal)

		 Spacer()
	  }
	  .padding()
	  .background(Color(.systemBackground))
	  .cornerRadius(20)
	  .shadow(radius: 10)
	  .gesture(DragGesture().onEnded { gesture in
		 if gesture.translation.width < -50 {
			dismissView()
		 }
	  })
   }

   func formatDistance(_ distance: HKQuantity?) -> String {
	  guard let distance = distance?.doubleValue(for: .meter()) else { return "--" }
	  return String(format: "%.2f km", distance / 1000)
   }

   func formatDuration(_ duration: TimeInterval) -> String {
	  let formatter = DateComponentsFormatter()
	  formatter.allowedUnits = [.hour, .minute, .second]
	  formatter.unitsStyle = .abbreviated
	  return formatter.string(from: duration) ?? "--"
   }

   func formatCalories(_ calories: HKQuantity?) -> String {
	  guard let calories = calories?.doubleValue(for: .kilocalorie()) else { return "--" }
	  return String(format: "%.0f kcal", calories)
   }

   func formatHeartRate(_ workout: HKWorkout) -> String {
	  if let heartRateSamples = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .heartRate)!)?.averageQuantity() {
		 let heartRateValue = heartRateSamples.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
		 return String(format: "%.0f bpm", heartRateValue)
	  }
	  return "--"
   }

   func dismissView() {
	  // Implement dismissal logic, such as setting a state variable in the parent view
   }
}
