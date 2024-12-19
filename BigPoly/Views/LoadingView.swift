import SwiftUI

struct LoadingView: View {
   var body: some View {
	  VStack {
		 ZStack {
			VStack {
			   Rectangle()
				  .fill(.blue.gradient)
				  .frame(height: 45)
			   Spacer()
			}
			VStack {
			   HStack {
				  Text("PolyView")
					 .foregroundStyle(.white)
					 .font(.system(size: 22))
					 .padding(EdgeInsets(top: 5, leading: 16, bottom: 16, trailing: 16))
				  Spacer()
				  Image(systemName: "map.circle")
					 .resizable()
					 .frame(width: 36, height: 36)
					 .foregroundColor(.white)
					 .padding(EdgeInsets(top: 3, leading: 16, bottom: 16, trailing: 16))
			   }
			   Spacer()
			}
			VStack {
			   Spacer(minLength: 75)
			   VStack {
				  Text("Loading Workouts...")
					 .foregroundColor(.white)
					 .font(.title2)
					 .padding(.bottom, 15)
				  ProgressView()
					 .scaleEffect(2, anchor: .center)
					 .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
			   }
			   Spacer()
			}
		 }
		 .frame(width: 300, height: 300)
		 .background(.blue.gradient.opacity(0.8))
		 .cornerRadius(20)
		 .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
		 .background(.white)
	  }
   }
}
