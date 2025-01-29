import SwiftUI
import MapKit

public class GradientPathRenderer: MKOverlayPathRenderer {
   var polyline: MKPolyline
   var colors: [CGColor]
   var showsBorder: Bool = false
   var borderColor: CGColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)

   public init(polyline: MKPolyline) {
	  self.polyline = polyline
	  self.colors = [
		 CGColor(red: 0, green: 1, blue: 0, alpha: 1),  // Green
		 CGColor(red: 1, green: 1, blue: 0, alpha: 1),  // Yellow
		 CGColor(red: 1, green: 0, blue: 0, alpha: 1)   // Red
	  ]
	  super.init(overlay: polyline)
   }

   public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
	  let baseWidth: CGFloat = self.lineWidth / zoomScale
	  if self.showsBorder {
		 context.setLineWidth(baseWidth * 2)
		 context.setLineJoin(.round)
		 context.setLineCap(.round)
		 context.addPath(self.path)
		 context.setStrokeColor(self.borderColor)
		 context.strokePath()
	  }

	  let colorspace = CGColorSpaceCreateDeviceRGB()
	  let locations: [CGFloat] = [0.0, 0.33, 0.66, 1.0] // Fixed stops for Green -> Yellow -> Red
	  guard let gradient = CGGradient(colorsSpace: colorspace, colors: colors as CFArray, locations: locations) else {
		 return
	  }

	  context.setLineWidth(baseWidth)
	  context.setLineJoin(.round)
	  context.setLineCap(.round)
	  context.addPath(self.path)
	  context.saveGState()
	  context.replacePathWithStrokedPath()
	  context.clip()

	  if polyline.pointCount > 1 {
		 for i in 0..<polyline.pointCount - 1 {
			let startPoint = self.point(for: polyline.points()[i])
			let endPoint = self.point(for: polyline.points()[i + 1])
			let progress = CGFloat(i) / CGFloat(polyline.pointCount - 1)

			let color = progress < 0.33 ? colors[0] : (progress < 0.66 ? colors[1] : colors[2])
			let segmentGradient = CGGradient(colorsSpace: colorspace, colors: [color, color] as CFArray, locations: [0.0, 1.0])
			context.drawLinearGradient(segmentGradient!, start: startPoint, end: endPoint, options: [])
		 }
	  } else {
		 context.setFillColor(colors.first ?? UIColor.red.cgColor)
		 context.fillPath()
	  }

	  context.restoreGState()
	  super.draw(mapRect, zoomScale: zoomScale, in: context)
   }

   public override func createPath() {
	  let path = CGMutablePath()
	  var pathIsEmpty = true

	  for i in 0..<self.polyline.pointCount {
		 let point = self.point(for: self.polyline.points()[i])
		 if pathIsEmpty {
			path.move(to: point)
			pathIsEmpty = false
		 } else {
			path.addLine(to: point)
		 }
	  }
	  self.path = path
   }
}
