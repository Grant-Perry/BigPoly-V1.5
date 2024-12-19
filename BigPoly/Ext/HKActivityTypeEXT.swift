import HealthKit

extension HKWorkoutActivityType {
   var name: String {
	  switch self {
		 case .walking: return "Walking"
		 case .running: return "Running"
		 case .cycling: return "Cycling"
		 default: return "Other"
	  }
   }
}
