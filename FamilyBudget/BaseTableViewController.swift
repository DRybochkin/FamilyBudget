//
//  BaseTableViewController.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 21.02.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name.FamilyBudgetNeedReloadData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showIndicator(_:)), name: NSNotification.Name.FamilyBudgetDataWillLoad, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideIndicator), name: NSNotification.Name.FamilyBudgetDataDidLoad, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func reloadData() {
        loadData()
        tableView.reloadData()
    }

    func loadData() {
    }

    func showIndicator(_ notification: Notification) {
        if (!(tableView.tableHeaderView is UIProgressView)) {
            let indicator = UIProgressView(progressViewStyle: .default)
            indicator.progressTintColor = UIColor.red
            indicator.center = view.center
            tableView.tableHeaderView = indicator
            indicator.progress = 0.0
        } else {
            if let array = notification.object as? [Any] {
                if (array.count > 2 && array[2] is Float) {
                    if let progress = array[2] as? Float {
                        if let progressView = tableView.tableHeaderView as? UIProgressView {
                            progressView.setProgress(progress, animated: true)
                        }
                        print("pregress \(progress)")
                    }
                }
            }
        }
    }

    func hideIndicator() {
        if (tableView.tableHeaderView is UIProgressView) {
            if let progressView = tableView.tableHeaderView as? UIProgressView {
                progressView.progress = 1.0
            }
            tableView.tableHeaderView = nil
        }
    }
}
