import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
extension UIColor {
    static var darkRed: UIColor {
        return UIColor(red: 139/255, green: 0, blue: 0, alpha: 1) // Dark Red RGB
    }
}
