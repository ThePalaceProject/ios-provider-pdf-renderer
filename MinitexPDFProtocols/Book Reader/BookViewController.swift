//
//  BookViewController.swift
//  BookReader
//
//  Created by Kishikawa Katsumi on 2017/07/03.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import PDFKit
import MessageUI
import UIKit.UIGestureRecognizerSubclass

@available(iOS 11.0, *)
class BookViewController: UIViewController, MinitexPDFViewController, UIPopoverPresentationControllerDelegate, PDFViewDelegate, SearchViewControllerDelegate, ThumbnailGridViewControllerDelegate, OutlineViewControllerDelegate, BookmarkViewControllerDelegate {

    var delegate: MinitexPDFViewControllerDelegate?

    required init?(file: URL,
                   openToPage page: MinitexPDFPage?,
                   bookmarks: [MinitexPDFPage]?,
                   annotations: [MinitexPDFAnnotation]?) {
        fatalError("This VC should only be initialized from a storyboard.")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var pdfDocument: PDFDocument?

    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfThumbnailViewContainer: UIView!
    @IBOutlet weak var pdfThumbnailView: PDFThumbnailView!
    @IBOutlet private weak var pdfThumbnailViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelContainer: UIView!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var pageNumberLabelContainer: UIView!

    let tableOfContentsToggleSegmentedControl = UISegmentedControl(items: [(#imageLiteral(resourceName: "Grid") as WrappedBundleImage).image, (#imageLiteral(resourceName: "List") as WrappedBundleImage).image, (#imageLiteral(resourceName: "Bookmark-N") as WrappedBundleImage).image])
    @IBOutlet weak var thumbnailGridViewConainer: UIView!
    @IBOutlet weak var outlineViewConainer: UIView!
    @IBOutlet weak var bookmarkViewConainer: UIView!

    var bookmarkButton: UIBarButtonItem!

    var searchNavigationController: UINavigationController?

    let barHideOnTapGestureRecognizer = UITapGestureRecognizer()
    let pdfViewGestureRecognizer = PDFViewGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(pdfViewPageChanged(_:)), name: .PDFViewPageChanged, object: nil)

        barHideOnTapGestureRecognizer.addTarget(self, action: #selector(gestureRecognizedToggleVisibility(_:)))
        view.addGestureRecognizer(barHideOnTapGestureRecognizer)

        tableOfContentsToggleSegmentedControl.selectedSegmentIndex = 0
        tableOfContentsToggleSegmentedControl.addTarget(self, action: #selector(toggleTableOfContentsView(_:)), for: .valueChanged)

        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
      pdfView.usePageViewController(true, withViewOptions: [UIPageViewController.OptionsKey.interPageSpacing: 20])

        pdfView.addGestureRecognizer(pdfViewGestureRecognizer)

        pdfView.document = pdfDocument

        pdfThumbnailView.layoutMode = .horizontal
        pdfThumbnailView.pdfView = pdfView

        titleLabel.text = pdfDocument?.documentAttributes?["Title"] as? String
        titleLabelContainer.layer.cornerRadius = 4
        pageNumberLabelContainer.layer.cornerRadius = 4

        resume()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustThumbnailViewHeight()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            self.adjustThumbnailViewHeight()
        }, completion: nil)
    }

    private func adjustThumbnailViewHeight() {
        self.pdfThumbnailViewHeightConstraint.constant = 44 + self.view.safeAreaInsets.bottom
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ThumbnailGridViewController {
            viewController.pdfDocument = pdfDocument
            viewController.delegate = self
        } else if let viewController = segue.destination as? OutlineViewController {
            viewController.pdfDocument = pdfDocument
            viewController.delegate = self
        } else if let viewController = segue.destination as? BookmarkViewController {
            viewController.pdfDocument = pdfDocument
            viewController.delegate = self
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func searchViewController(_ searchViewController: SearchViewController, didSelectSearchResult selection: PDFSelection) {
        selection.color = .yellow
        pdfView.currentSelection = selection
        pdfView.go(to: selection)
        showBars()
    }

    func thumbnailGridViewController(_ thumbnailGridViewController: ThumbnailGridViewController, didSelectPage page: PDFPage) {
        resume()
        pdfView.go(to: page)
    }

    func outlineViewController(_ outlineViewController: OutlineViewController, didSelectOutlineAt destination: PDFDestination) {
        resume()
        pdfView.go(to: destination)
    }

    func bookmarkViewController(_ bookmarkViewController: BookmarkViewController, didSelectPage page: PDFPage) {
        resume()
        pdfView.go(to: page)
    }

    private func resume() {
        let backButton = UIBarButtonItem(image: (#imageLiteral(resourceName: "Chevron") as WrappedBundleImage).image, style: .plain, target: self, action: #selector(back(_:)))
        let tableOfContentsButton = UIBarButtonItem(image: (#imageLiteral(resourceName: "List") as WrappedBundleImage).image, style: .plain, target: self, action: #selector(showTableOfContents(_:)))
        navigationItem.leftBarButtonItems = [backButton, tableOfContentsButton]

        let searchButton = UIBarButtonItem(image: (#imageLiteral(resourceName: "Search") as WrappedBundleImage).image, style: .plain, target: self, action: #selector(showSearchView(_:)))
        bookmarkButton = UIBarButtonItem(image: (#imageLiteral(resourceName: "Bookmark-N") as WrappedBundleImage).image, style: .plain, target: self, action: #selector(addOrRemoveBookmark(_:)))
        navigationItem.rightBarButtonItems = [bookmarkButton, searchButton]

        pdfThumbnailViewContainer.alpha = 1

        pdfView.isHidden = false
        titleLabelContainer.alpha = 1
        pageNumberLabelContainer.alpha = 1
        thumbnailGridViewConainer.isHidden = true
        outlineViewConainer.isHidden = true

        barHideOnTapGestureRecognizer.isEnabled = true

        updateBookmarkStatus()
        updatePageNumberLabel()
    }

    private func showTableOfContents() {
        view.exchangeSubview(at: 0, withSubviewAt: 1)
        view.exchangeSubview(at: 0, withSubviewAt: 2)

        let backButton = UIBarButtonItem(image: (#imageLiteral(resourceName: "Chevron") as WrappedBundleImage).image, style: .plain, target: self, action: #selector(back(_:)))
        let tableOfContentsToggleBarButton = UIBarButtonItem(customView: tableOfContentsToggleSegmentedControl)
        let resumeBarButton = UIBarButtonItem(title: NSLocalizedString("Resume", comment: ""), style: .plain, target: self, action: #selector(resume(_:)))
        navigationItem.leftBarButtonItems = [backButton, tableOfContentsToggleBarButton]
        navigationItem.rightBarButtonItems = [resumeBarButton]

        pdfThumbnailViewContainer.alpha = 0

        toggleTableOfContentsView(tableOfContentsToggleSegmentedControl)

        barHideOnTapGestureRecognizer.isEnabled = false
    }

    @objc func resume(_ sender: UIBarButtonItem) {
        resume()
    }

    @objc func back(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @objc func showTableOfContents(_ sender: UIBarButtonItem) {
        showTableOfContents()
    }

    @objc func showSearchView(_ sender: UIBarButtonItem) {
        if let searchNavigationController = self.searchNavigationController {
            present(searchNavigationController, animated: true, completion: nil)
        } else if let navigationController = storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? UINavigationController,
            let searchViewController = navigationController.topViewController as? SearchViewController {
            searchViewController.pdfDocument = pdfDocument
            searchViewController.delegate = self
            present(navigationController, animated: true, completion: nil)

            searchNavigationController = navigationController
        }
    }

    @objc func addOrRemoveBookmark(_ sender: UIBarButtonItem) {
        if let documentURL = pdfDocument?.documentURL?.absoluteString {
            var bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int] ?? [Int]()
            if let currentPage = pdfView.currentPage,
                let pageIndex = pdfDocument?.index(for: currentPage) {
                if let index = bookmarks.index(of: pageIndex) {
                    bookmarks.remove(at: index)
                    UserDefaults.standard.set(bookmarks, forKey: documentURL)
                    bookmarkButton.image = (#imageLiteral(resourceName: "Bookmark-N") as WrappedBundleImage).image
                } else {
                    UserDefaults.standard.set((bookmarks + [pageIndex]).sorted(), forKey: documentURL)
                    bookmarkButton.image = (#imageLiteral(resourceName: "Bookmark-P") as WrappedBundleImage).image
                }
            }
        }
    }

    @objc func toggleTableOfContentsView(_ sender: UISegmentedControl) {
        pdfView.isHidden = true
        titleLabelContainer.alpha = 0
        pageNumberLabelContainer.alpha = 0

        if tableOfContentsToggleSegmentedControl.selectedSegmentIndex == 0 {
            thumbnailGridViewConainer.isHidden = false
            outlineViewConainer.isHidden = true
            bookmarkViewConainer.isHidden = true
        } else if tableOfContentsToggleSegmentedControl.selectedSegmentIndex == 1 {
            thumbnailGridViewConainer.isHidden = true
            outlineViewConainer.isHidden = false
            bookmarkViewConainer.isHidden = true
        } else {
            thumbnailGridViewConainer.isHidden = true
            outlineViewConainer.isHidden = true
            bookmarkViewConainer.isHidden = false
        }
    }

    @objc func pdfViewPageChanged(_ notification: Notification) {
        if pdfViewGestureRecognizer.isTracking {
            hideBars()
        }
        updateBookmarkStatus()
        updatePageNumberLabel()
    }

    @objc func gestureRecognizedToggleVisibility(_ gestureRecognizer: UITapGestureRecognizer) {
        if let navigationController = navigationController {
            if navigationController.navigationBar.alpha > 0 {
                hideBars()
            } else {
                showBars()
            }
        }
    }

    private func updateBookmarkStatus() {
        if let documentURL = pdfDocument?.documentURL?.absoluteString,
            let bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int],
            let currentPage = pdfView.currentPage,
            let index = pdfDocument?.index(for: currentPage) {
            bookmarkButton.image = bookmarks.contains(index) ? (#imageLiteral(resourceName: "Bookmark-P") as WrappedBundleImage).image : (#imageLiteral(resourceName: "Bookmark-N") as WrappedBundleImage).image
        }
    }

    private func updatePageNumberLabel() {
        if let currentPage = pdfView.currentPage, let index = pdfDocument?.index(for: currentPage), let pageCount = pdfDocument?.pageCount {
            pageNumberLabel.text = String(format: "%d/%d", index + 1, pageCount)
        } else {
            pageNumberLabel.text = nil
        }
    }

    private func showBars() {
        if let navigationController = navigationController {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                navigationController.navigationBar.alpha = 1
                self.pdfThumbnailViewContainer.alpha = 1
                self.titleLabelContainer.alpha = 1
                self.pageNumberLabelContainer.alpha = 1
            }
        }
    }

    private func hideBars() {
        if let navigationController = navigationController {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                navigationController.navigationBar.alpha = 0
                self.pdfThumbnailViewContainer.alpha = 0
                self.titleLabelContainer.alpha = 0
                self.pageNumberLabelContainer.alpha = 0
            }
        }
    }
}

class PDFViewGestureRecognizer: UIGestureRecognizer {
    var isTracking = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        isTracking = false
    }
}
