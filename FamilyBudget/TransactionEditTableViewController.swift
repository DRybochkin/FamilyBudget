//
//  TransactionEditTableViewController.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 20.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import os.log
import UIKit

protocol SelectCategoryDelegate: NSObjectProtocol {
    var categoryId: Int64! {
        get
        set
    }
}

class TransactionEditTableViewController: BaseTableViewController, UIPopoverPresentationControllerDelegate, SelectCategoryDelegate {
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var dueDate: UIDatePicker!
    @IBOutlet weak var transactionDescription: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var errorAmountLabel: UILabel!

    private var transaction: DOTransaction!
    private var category: DOCategory!

    var transationId: Int64!
    var categoryType: CategoryTypes!
    var categoryId: Int64! {
        didSet {
            category = DOCategoryDataHelper.find(id: categoryId)
            if (categoryLabel != nil) {
                categoryLabel.text = category.categoryTitle
                checkState()
            }
        }
    }

    override func loadData() {
        if (transationId != nil && transationId > 0) {
            transaction = DOTransactionDataHelper.find(id: transationId)
            category = DOCategoryDataHelper.find(id: transaction.categoryId)
        }
    }

    override func reloadData() {
        loadData()

        if (transaction != nil) {
            if (category?.categoryType == CategoryTypes.cost) {
                amount.text = transaction?.transactionCost.toString(locale: "ru_RU")
            } else {
                amount.text = transaction?.transactionProfit.toString(locale: "ru_RU")
            }

            dueDate.date = (transaction?.transactionDueDate.date())!
            transactionDescription.text = transaction?.transactionDescription
            categoryLabel.text = category?.categoryTitle
        } else {
            transaction = DOTransaction(transactionId: 0, userId: SQLiteDataStore.sharedInstance.currentUser.userId, categoryId: categoryId != nil ? categoryId : -1, transactionDueDate: Int64(Date().timeIntervalSince1970), transactionCost: 0.0, transactionProfit: 0.0, transactionDescription: "", transactionUploaded: 0, transactionDeleted: 0)
            if (categoryId != nil) {
                categoryLabel.text = category?.categoryTitle
            }
        }
        checkState()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.currentContext
    }

    private func checkState() {
        let sum: Double = (amount.text?.toNumber()?.doubleValue)!
        saveBarButton.isEnabled = sum > 0.0 && transaction != nil && categoryId != nil && (category?.categoryId)! > 0 && (sum != transaction.transactionCost.doubleValue + transaction.transactionProfit.doubleValue || category.categoryId != transaction.categoryId || transaction.transactionDueDate != Int64(dueDate.date.timeIntervalSince1970) || transaction.transactionDescription != transactionDescription.text)
        errorAmountLabel.isHidden = sum > 0.0
        categoryLabel.textColor = transaction.categoryId >= 0 ? UIColor.black : UIColor.red
    }

    @IBAction func editingChanged(_ sender: Any) {
        checkState()
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.

        if let tmpController = presentingViewController {
            dismiss(animated: true, completion: { () -> Void in
                tmpController.dismiss(animated: true, completion: nil)
            })
        } else {
            fatalError("The ViewController is not inside a navigation controller.")
        }
    }

    @IBAction func save(_ sender: Any) {
        let numberAmount: NSNumber = (amount.text?.toNumber())!
        if (transaction != nil && numberAmount.doubleValue != 0 && (category?.categoryId)! > 0) {
            transaction?.categoryId = (category?.categoryId)!
            transaction?.transactionDescription = transactionDescription.text!
            transaction?.transactionDueDate = Int64(dueDate.date.timeIntervalSince1970)
            if (transaction.transactionId > 0) {
                transaction.transactionUploaded = 2
            }

            if (category?.categoryType == CategoryTypes.cost) {
                transaction?.transactionCost = numberAmount
            } else {
                transaction?.transactionProfit = numberAmount
            }

            _ = DOTransactionDataHelper.resolve(item: transaction!)
            dismiss(animated: true, completion: nil)
        } else {
            /*show error*/
        }
    }

    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        super.prepare(for: segue, sender: sender)

        if (segue.identifier == "SelectCategory") {
            guard let nc = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let vc = nc.viewControllers[0] as? SelectCategoryTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            vc.title = "Выберите категорию"
            if (category != nil && category.categoryId > 0) {
                vc.categoryId = category.categoryId
            } else {
                vc.categoryType = categoryType
            }
            vc.selectCategoryDelegate = self

            return
        }
    }
}
