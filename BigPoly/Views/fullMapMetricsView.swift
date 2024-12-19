import SwiftUI

struct fullMapMetricsView: View {
   var cityName: String
   var workoutDate: Date
   var distance: Double

   var body: some View {
	  HStack {
		 VStack(alignment: .leading) {
			Text(cityName)
			   .font(.title)
			   .bold()
			Text("  \(workoutDate, formatter: dateFormatter)")
		 }
		 Spacer()
		 Text("Distance: \(String(format: "%.2f", distance))")
	  }
	  .padding()
	  .frame(maxWidth: .infinity)
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
