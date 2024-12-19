import SwiftUI
import HealthKit

struct WorkoutRouteView: View {
   let workout: HKWorkout
   @ObservedObject var polyViewModel: PolyViewModel
   
   @State private var cityName: String = "Loading..."
   @State private var distance: Double = 0.0

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

		 VStack(alignment: .leading, spacing: 1) {
			// Address line removed since we are no longer fetching a detailed address, just city name.
			Text("Distance: \(String(format: "%.2f", distance))")
			   .font(.system(size: 18).bold())
			   .foregroundColor(.secondary)
			   .frame(maxWidth: .infinity, alignment: .trailing)
			   .padding(.trailing, 30)

			HStack {
			   Text("miles")
				  .font(.system(size: 8))
				  .frame(maxWidth: .infinity, alignment: .trailing)
				  .padding(.trailing, 30)
			}
		 }
		 .foregroundColor(.white)
		 .padding(.leading, 20)
		 .frame(maxWidth: .infinity, alignment: .leading)

	  }
	  .frame(width: UIScreen.main.bounds.width * 0.65, height: 105)
	  .background(
		 LinearGradient(colors: [.gpDeltaPurple, .clear], startPoint: .top, endPoint: .bottom)
	  )
	  .cornerRadius(10)
	  .onAppear {
		 Task {
			if let fetchedCity = await polyViewModel.fetchCityName(for: workout) {
			   cityName = fetchedCity
			} else {
			   cityName = "Unknown City"
			}
			distance = await polyViewModel.fetchDistance(for: workout) ?? 0
		 }
	  }
	  .preferredColorScheme(.dark)

   }
}
