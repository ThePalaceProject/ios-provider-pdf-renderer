import Foundation
import UIKit

extension Bundle {
  static func pdfRendererProvider() -> Bundle? {
    return Bundle(identifier: "edu.umn.minitex.simplye.MinitexPDFProtocols")
  }
}

struct WrappedBundleImage: _ExpressibleByImageLiteral {
  let image: UIImage

  init(imageLiteralResourceName name: String) {
    let bundle = Bundle.pdfRendererProvider()!
    image = UIImage(named: name, in: bundle, compatibleWith: nil)!
  }
}
