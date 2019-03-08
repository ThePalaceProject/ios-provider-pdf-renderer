//
//  ActionMenuViewController.swift
//  BookReader
//
//  Created by Kishikawa Katsumi on 2017/07/04.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit

@available(iOS 11.0, *)
class ActionMenuViewController: UITableViewController {
    weak var delegate: ActionMenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false
        tableView.separatorInset = .zero
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate?.actionMenuViewControllerShareDocument(self)
        } else if indexPath.row == 1 {
            delegate?.actionMenuViewControllerPrintDocument(self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

@available(iOS 11.0, *)
protocol ActionMenuViewControllerDelegate: class {
    func actionMenuViewControllerShareDocument(_ actionMenuViewController: ActionMenuViewController)
    func actionMenuViewControllerPrintDocument(_ actionMenuViewController: ActionMenuViewController)
}
