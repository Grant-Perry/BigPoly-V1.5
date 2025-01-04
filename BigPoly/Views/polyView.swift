//import SwiftUI
//import HealthKit
//
//struct PolyView: View {
//   @ObservedObject var polyViewModel: PolyViewModel
//   @State private var workoutLimit = 150
//   @State private var showingFilterSheet = false
//
//   var body: some View {
//	  VStack(spacing: 0) {
//		 Text("Workouts")
//			.font(.system(size: 36, weight: .bold))
//			.frame(maxWidth: .infinity, alignment: .leading)
//			.padding(.horizontal)
//			.padding(.top)
//
//		 Button(action: {
//			showingFilterSheet.toggle()
//		 }) {
//			Text("Sort & Filter")
//			   .foregroundColor(.gpMinty)
//			   .font(.system(size: 20))
//		 }
//		 .frame(maxWidth: .infinity, alignment: .leading)
//		 .padding(.horizontal)
//		 .padding(.bottom, -3)
//
//		 if polyViewModel.isLoading {
//			LoadingView()
//		 } else {
//			ScrollView {
//			   LazyVStack(spacing: 12) {
//				  ForEach(polyViewModel.workouts, id: \.uuid) { workout in
//					 NavigationLink(destination: FullMapView(workout: workout, polyViewModel: polyViewModel)) {
//						WorkoutRouteView(workout: workout, polyViewModel: polyViewModel)
//					 }
//				  }
//			   }
//			   .padding(.top, 4)
//
//			   Text("\(AppConstants.appName) v\(AppConstants.getVersion())")
//				  .font(.system(size: 12))
//				  .foregroundColor(.secondary)
//				  .padding(.top, 20)
//				  .padding(.bottom, 10)
//			}
//		 }
//	  }
//	  .onAppear {
//		 polyViewModel.limit = workoutLimit
//		 polyViewModel.loadWorkouts(page: 0)
//	  }
//   }
//}
