//
//  CategoryEditTableViewController.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 21.02.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit

class CategoryEditTableViewController: UITableViewController {
    @IBOutlet weak var categoryTitle: UITextField!
    @IBOutlet weak var errorCategoryTitleLabel: UILabel!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!

    var category: DOCategory!
    var categoryId: Int64!

    override func viewDidLoad() {
        super.viewDidLoad()

        if (category == nil) {
            category = DOCategoryDataHelper.find(id: categoryId)
        }

        categoryTitle.text = category.categoryTitle

        checkState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.currentContext
    }

    func checkState() {
        let title = categoryTitle.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        saveBarButton.isEnabled = title.characters.isEmpty && (category == nil || title != category.categoryTitle)
        errorCategoryTitleLabel.isHidden = title.characters.isEmpty
    }

    @IBAction func editingChanged(_ sender: Any) {
        checkState()
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {
        if (category != nil) {
            category?.categoryTitle = categoryTitle.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if (category.categoryId > 0) {
                category?.categoryUploaded = 2
            }
            _ = DOCategoryDataHelper.resolve(item: category!)
            dismiss(animated: true, completion: nil)
        } else {
            /*Show error message*/
        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //}
}
