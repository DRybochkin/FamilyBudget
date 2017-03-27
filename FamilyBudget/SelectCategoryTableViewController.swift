//
//  SelectCategoryTableViewController.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 22.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit

class SelectCategoryTableViewController: BaseTableViewController, UIPopoverPresentationControllerDelegate {
    var categoryId: Int64!
    var categoryType: CategoryTypes!
    weak var selectCategoryDelegate: SelectCategoryDelegate!

    private var categories: [DOCategory] = []
    private var selectedIndexPath: IndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    override func loadData() {
        if (categoryId != nil && categoryId > 0) {
            let cat = DOCategoryDataHelper.find(id: categoryId)
            categoryType = cat?.categoryType
        }
        if (categoryType != nil) {
            categories = DOCategoryDataHelper.getAll(type: (categoryType)!)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RI_SelectCategoryTableViewCell", for: indexPath) as? SelectCategoryTableViewCell {
            cell.categoryTitle?.text = categories[indexPath.item].categoryTitle
            if (categoryId != nil && categoryId == categories[indexPath.item].categoryId) {
                selectedIndexPath = indexPath
                cell.checkButton.isHidden = false
            } else {
                cell.checkButton.isHidden = true
            }
            cell.editButton.tag = indexPath.row
            return cell
        } else {
            assert(false, "Unknown cell type." )
        }
        assert(false, "Unknown index.")
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (categoryId == nil || categoryId != categories[indexPath.item].categoryId) {
            categoryId = categories[indexPath.item].categoryId
            if (selectedIndexPath != nil) {
                tableView.reloadRows(at: [selectedIndexPath, indexPath], with: UITableViewRowAnimation.automatic)
            } else {
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
            selectCategoryDelegate?.categoryId = categoryId
            dismiss(animated: true, completion: nil)
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.currentContext
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        selectCategoryDelegate?.categoryId = categoryId
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if (segue.identifier == "AddCategory") {
            guard let nc = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let vc = nc.viewControllers[0] as? CategoryEditTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            vc.title = "Новая категория"

            //let cat = DOCategoryDataHelper.find(id: categoryId)
            vc.category = DOCategory(categoryId: 0, userId: SQLiteDataStore.sharedInstance.currentUser.userId, categoryTitle: "", categoryType: categoryType, categoryUploaded: 0, categoryDeleted: 0)
            return
        } else if (segue.identifier == "EditCategory") {
            guard let nc = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination navigation: \(segue.destination)")
            }

            guard let vc = nc.viewControllers[0] as? CategoryEditTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let editButton = sender as? UIButton else {
                fatalError("Unexpected sender: \(segue.destination)")
            }

            vc.title = "Редактирование категории"
            vc.category = categories[editButton.tag]

            return
        }
    }

}
