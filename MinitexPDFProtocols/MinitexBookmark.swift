//
//  MinitexBookmark.swift
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
  var bbox: [Double]?
  // optional
  var color: String?
  // optional
  var opacity: Float?
  // required
  var pageIndex: UInt?
  // required
  var rects: [[Double]]?
  // required
  var type: String?
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

public protocol MinitexPDFViewControllerDelegate: class {
  func userDidNavigate(page: Int)
  func saveBookmarks(pageNumbers: [UInt])
  func saveAnnotations(annotationsData: [Data])
  func saveAnnotations(annotations: [MinitexPDFAnnotation])
}

public protocol MinitexViewControllerFactory {
  func createViewController(documentURL: URL, openToPage page: UInt, bookmarks pages: [UInt],
  annotations annotationObjects: [MinitexPDFAnnotation],
  PSPDFKitLicense: String, delegate: MinitexPDFViewControllerDelegate) -> UIViewController
}

