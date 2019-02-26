//
//  MinitexPDFProtocols.swift
//  MinitexPDFProtocols
//
//  Created by Vui Nguyen on 4/26/18.
//  Copyright © 2018 Minitex. All rights reserved.
//

import Foundation
import UIKit

// the items that are marked required are needed to
// recreate an annotation in PSPDFKit later
@objc public class MinitexPDFAnnotation: NSObject, Codable {
  // required
  public let pageIndex: UInt
  // required
  public let type: String
  // required
  public let bbox: String
  // required
  public let rects: [String]

  // optional
  public let color: String?
  // optional
  public let opacity: Float?
  // optional
  // we store this in case the field parsing fails, then we have the original JSON
  public let JSONData: Data?

  // optional
  // this value cannot be set in PSPDFKit
  //var v: Int?

  public init(pageIndex: UInt, type: String, bbox: String, rects: [String],
              color: String?, opacity: Float?, JSONData: Data?) {
    self.pageIndex = pageIndex
    self.type = type
    self.bbox = bbox
    self.rects = rects
    self.color = color
    self.opacity = opacity
    self.JSONData = JSONData
  }
}


@objc public protocol MinitexPDFViewController: class {
  // we have to pass in a dictionary because @objc protocol function
  // cannot accept multiple parameters
  @objc init(dictionary: [String: Any])
}


@objc public protocol MinitexPDFViewControllerDelegate: class {
  @objc func userDidNavigate(page: Int)
  @objc func saveBookmarks(pageNumbers: [UInt])
  @objc func saveAnnotations(annotations: [MinitexPDFAnnotation])
  @objc func willMoveToMinitexParentController(parent: UIViewController?)
}


@objc public class MinitexPDFViewControllerFactory: NSObject {
  @objc public static func createPDFViewController(dictionary: [String: Any]) -> MinitexPDFViewController? {

    guard let pdfViewControllerClass = NSClassFromString("PDF.PDFViewController")
                                        as? MinitexPDFViewController.Type else {
      return nil
    }

    let pdfViewController = pdfViewControllerClass.init(dictionary: dictionary)
    return pdfViewController
  }
}
