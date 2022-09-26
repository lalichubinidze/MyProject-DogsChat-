
import Foundation
import UIKit


extension Date {

    func longDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }


    func stringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyyHHmmss"
        return dateFormatter.string(from: self)
    }

    func interval(ofComponnent comp: Calendar.Component, fromDate date: Date) -> Int {

        let currentCalendar = Calendar.current

        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }

        return start - end
    }
}
extension UIColor {
    func primary() -> UIColor {
        return  UIColor(red: 100/255, green: 80/255, blue: 85/255, alpha: 1)
    }

    func tabBarUnselected() -> UIColor {
        return UIColor(red: 255/255, green: 216/255, blue: 223/255, alpha: 1)
    }
    static var sampleRed = UIColor(red: 252 / 255, green: 70 / 255, blue: 93 / 255, alpha: 1)
    static var sampleGreen = UIColor(red: 49 / 255, green: 193 / 255, blue: 109 / 255, alpha: 1)
    static var sampleBlue = UIColor(red: 52 / 255, green: 154 / 255, blue: 254 / 255, alpha: 1)
}

extension UIImage {
    var isPortrait : Bool { return size.height > size.width }
    var isLandscape : Bool { return size.width > size.height}
    var breedth: CGFloat { return min(size.width, size.height)}
    var breadthSize : CGSize { return CGSize(width: breedth, height: breedth)}
    var breethRec:  CGRect {return CGRect(origin: .zero, size: breadthSize)}

    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let cgImage = cgImage? .cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breethRec).addClip()
        UIImage(cgImage: cgImage).draw(in: breethRec)

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension NSAttributedString.Key {
    static var shadowAttribute: NSShadow = {
      let shadow = NSShadow()
      shadow.shadowOffset = CGSize(width: 0, height: 1)
      shadow.shadowBlurRadius = 2
      shadow.shadowColor = UIColor.black.withAlphaComponent(0.3)
      return shadow
    }()

    static var titleAttributes: [NSAttributedString.Key: Any] = [
      // swiftlint:disable:next force_unwrapping
      NSAttributedString.Key.font: UIFont(name: "ArialRoundedMTBold", size: 25)!,
      NSAttributedString.Key.foregroundColor: UIColor.white,
      NSAttributedString.Key.shadow: NSAttributedString.Key.shadowAttribute
    ]

    static var subtitleAttributes: [NSAttributedString.Key: Any] = [
      // swiftlint:disable:next force_unwrapping
      NSAttributedString.Key.font: UIFont(name: "Arial", size: 17)!,
      NSAttributedString.Key.foregroundColor: UIColor.white,
      NSAttributedString.Key.shadow: NSAttributedString.Key.shadowAttribute
    ]

  static var overlayAttributes: [NSAttributedString.Key: Any] = [
    // swiftlint:disable:next force_unwrapping
    NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 42)!,
    NSAttributedString.Key.kern: 5.0
  ]
}

extension UIView {

    func applyShadow(radius: CGFloat,
                     opacity: Float,
                     offset: CGSize,
                     color: UIColor = .black) {
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
    }

    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat = 0,
                height: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false

        var anchors = [NSLayoutConstraint]()

        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: paddingTop))
        }
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: paddingLeft))
        }
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom))
        }
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -paddingRight))
        }
        if width > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: width))
        }
        if height > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: height))
        }

        anchors.forEach { $0.isActive = true }

        return anchors
    }

    @discardableResult
    func anchorToSuperview() -> [NSLayoutConstraint] {
        return anchor(top: superview?.topAnchor,
                      left: superview?.leftAnchor,
                      bottom: superview?.bottomAnchor,
                      right: superview?.rightAnchor)
    }
}






