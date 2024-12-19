import SwiftUI
import MapKit

public class GradientPathRenderer: MKOverlayPathRenderer {
   var polyline: MKPolyline
   var colors: [CGColor]
   var showsBorder: Bool = false
   var borderColor: CGColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)

   public init(polyline: MKPolyline, colors: [CGColor]) {
	  self.polyline = polyline
	  self.colors = colors
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
	  // Evenly spaced stops
	  let stopCount = colors.count
	  let increments = 1.0 / CGFloat(stopCount - 1)
	  var locations: [CGFloat] = []
	  for i in 0..<stopCount {
		 locations.append(CGFloat(i) * increments)
	  }

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

	  // Instead of using boundingBox, calculate start and end from the route's first and last coordinates
	  if polyline.pointCount > 1 {
		 let firstMapPoint = polyline.points()[0]
		 let lastMapPoint = polyline.points()[polyline.pointCount - 1]

		 // Convert to view points
		 let firstPoint = self.point(for: firstMapPoint)
		 let lastPoint = self.point(for: lastMapPoint)

		 // Use these points for the gradient direction
		 let gradientStart = firstPoint
		 let gradientEnd = lastPoint

		 context.drawLinearGradient(gradient,
									start: gradientStart,
									end: gradientEnd,
									options: .drawsBeforeStartLocation)
	  } else {
		 // If we don't have at least two points, just fill with the first color
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
