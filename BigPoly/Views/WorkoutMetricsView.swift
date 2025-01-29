import SwiftUI
import HealthKit

struct WorkoutMetricsView: View {
   var workout: WorkoutCore
   var metricMeta: MetricMeta

   var body: some View {
	  VStack(spacing: 0) {
		 HStack {
			VStack(alignment: .leading) {
			   Text(metricMeta.cityName)
				  .font(.title)
				  .bold()
			   Text("  \(metricMeta.totalTime)")
			}
			Spacer()
			VStack(alignment: .trailing) {
			   Text("Distance: \(String(format: "%.2f", workout.distance)) mi")
				  .bold()
			   if let speed = metricMeta.averageSpeed {
				  Text("Avg Speed: \(String(format: "%.2f", speed)) mph")
			   }
			}
		 }
		 .padding()
		 NavigationLink(destination: MetricsView(workout: workout, metricMeta: metricMeta)) {
			Image(systemName: "lasso.badge.sparkles")
			   .font(.system(size: 24))
			   .foregroundColor(.white)
		 }
		 .position(x: UIScreen.main.bounds.width - 50, y: 0)
	  }
	  .frame(height: 125)
	  .background(.blue.gradient)
	  .foregroundColor(.white)
	  .cornerRadius(8)
	  .shadow(color: .gray, radius: 5, x: 0, y: 2)
   }

   private var dateFormatter: DateFormatter {
	  let formatter = DateFormatter()
	  formatter.dateStyle = .medium
	  return formatter
   }
}
