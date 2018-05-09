//
//  MinitexPDFProtocols.swift
//  MinitexPDFProtocols
//
//  Created by Vui Nguyen on 4/26/18.
//  Copyright © 2018 Minitex. All rights reserved.
//

import Foundation

// the items that are marked required are needed to
// recreate an annotation in PSPDFKit later
public class MinitexPDFAnnotation: Codable {
  // required
  public var bbox: [Double]?
  // optional
  public var color: String?
  // optional
  public var opacity: Float?
  // required
  public var pageIndex: UInt?
  // required
  public var rects: [[Double]]?
  // required
  public var type: String?
  // optional
  // this value cannot be set from PSPDFKit
  //var v: Int?

  // optional
  public var JSONData: Data?

  public init(JSONData: Data) {
    self.JSONData = JSONData
  }

  public init() {

  }
}


@objc public protocol MinitexPDFViewController: class {
  // we have to pass in a dictionary because @objc protocol function
  // cannot accept multiple parameters
  init(dictionary: [String: Any])
}


public protocol MinitexPDFViewControllerDelegate: class {
  func userDidNavigate(page: Int)
  func saveBookmarks(pageNumbers: [UInt])
  func saveAnnotations(annotationsData: [Data])
  func saveAnnotations(annotations: [MinitexPDFAnnotation])
}

public class MinitexPDFViewControllerFactory {
  public static func createPDFViewController(dictionary: [String: Any]) -> MinitexPDFViewController? {

    guard let pdfViewControllerClass = NSClassFromString("PDF.PDFViewController")
                                        as? MinitexPDFViewController.Type else {
      return nil
    }

    let pdfViewController = pdfViewControllerClass.init(dictionary: dictionary)
    return pdfViewController
  }
}
