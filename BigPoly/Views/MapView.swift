import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
   var polyline: MKPolyline
   var region: MKCoordinateRegion

   func makeUIView(context: Context) -> MKMapView {
	  let mapView = MKMapView()
	  mapView.setRegion(region, animated: true)
	  return mapView
   }

   func updateUIView(_ uiView: MKMapView, context: Context) {
	  uiView.delegate = context.coordinator
	  uiView.removeOverlays(uiView.overlays)
	  uiView.addOverlay(polyline)
	  uiView.setRegion(region, animated: true)
   }

   func makeCoordinator() -> Coordinator {
	  Coordinator(self)
   }

   class Coordinator: NSObject, MKMapViewDelegate {
	  var parentView: MapView

	  init(_ parentView: MapView) {
		 self.parentView = parentView
	  }

	  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		 if let lineOverlay = overlay as? MKPolyline {
			let renderer = MKPolylineRenderer(polyline: lineOverlay)
			renderer.strokeColor = .blue
			renderer.lineWidth = 4
			return renderer
		 }
		 return MKOverlayRenderer(overlay: overlay)
	  }
   }
}
