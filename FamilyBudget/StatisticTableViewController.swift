//
//  StatisticTableViewController.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 27.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit
import os.log
import Charts

protocol StatisticPageViewControllerDelegate {
    weak var pageViewController: StatisticPageViewController! { get set }
}

class StatisticTableViewController: BaseTableViewController, StatisticPageViewControllerDelegate {
    var sections: [Section] = []
    weak var pageViewController: StatisticPageViewController!
    var barButtons: [UIBarButtonItem]! = []
    
    var editButton: UIBarButtonItem {
        get {
            let results = barButtons.filter { el in el.tag == 1 }
            if (results.count > 0) {
                return results[0]
            }
            let button = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(edit(sender:)))
            button.tag = 1
            return button
        }
    }
    var addCostTransactionButton: UIBarButtonItem {
        get {
            let results = barButtons.filter { el in el.tag == 2 }
            if (results.count > 0) {
                return results[0]
            }
            let button = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(addCostTransaction(sender:)))
            button.tag = 2
            return button
        }
    }
    var addProfitTransactionButton: UIBarButtonItem {
        get {
            let results = barButtons.filter { el in el.tag == 3 }
            if (results.count > 0) {
                return results[0]
            }
            let button = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addProfitTransaction(sender:)))
            button.tag = 3
            return button
        }
    }

    var addCostCategoryButton: UIBarButtonItem {
        get {
            let results = barButtons.filter { el in el.tag == 4 }
            if (results.count > 0) {
                return results[0]
            }
            let button = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addCostCategory(sender:)))
            button.tag = 4
            return button
        }
    }
    var addProfitCategoryButton: UIBarButtonItem {
        get {
            let results = barButtons.filter { el in el.tag == 5 }
            if (results.count > 0) {
                return results[0]
            }
            let button = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addProfitCategory(sender:)))
            button.tag = 5
            return button
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40.0
        
        loadData()
    }
    
    override func loadData() {
        for item in sections {
            
            item.loadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        if (pageViewController != nil) {
            pageViewController.navigationItem.rightBarButtonItems = barButtons
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (sections[section].count > 0) {
            return sections[section].parsedTitle
        } else {
            return nil
        }
    }
    
    private func createCell (item: DOStatisticData, indexPath: IndexPath, isSimple: Bool = false) -> UITableViewCell {
        if (item.dataTypes.contains(StatisticDataTypes.Transaction)) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "RI_TransactionTableViewCell", for: indexPath) as? TransactionTableViewCell {
                InitCellHelpers.initTransactionCell(cell: cell, statistic: item)
                return cell
            } else {
                assert(false, "Unknown cell type.")
            }
        } else if (!item.dataTypes.contains(StatisticDataTypes.Category)) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "RI_TotalTableViewCell", for: indexPath) as? TotalTableViewCell {
                InitCellHelpers.initTotalCell(cell: cell, statistic: item)
                if ((pageViewController.statistic != nil && item.dataTypes == pageViewController.statistic.dataTypes) || item.isEmpty) {
                    cell.accessoryType = .none
                } else {
                    cell.accessoryType = .disclosureIndicator
                }
                return cell
            } else {
                assert(false, "Unknown cell type.")
            }
        } else {
            if (isSimple) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "RI_SimpleTableViewCell", for: indexPath) as? SimpleTableViewCell {
                    InitCellHelpers.initSimpleCell(cell: cell, statistic: item)
                    if ((pageViewController.statistic != nil && item.dataTypes == pageViewController.statistic.dataTypes) || item.isEmpty) {
                        cell.accessoryType = .none
                    } else {
                        cell.accessoryType = .disclosureIndicator
                    }
                    return cell
                } else {
                    assert(false, "Unknown cell type.")
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "RI_ColoredImageTableViewCell", for: indexPath) as? ColoredImageTableViewCell {
                    InitCellHelpers.initColoredCell(cell: cell, statistic: item)
                    if ((pageViewController.statistic != nil && item.dataTypes == pageViewController.statistic.dataTypes) || item.isEmpty) {
                        cell.accessoryType = .none
                    } else {
                        cell.accessoryType = .disclosureIndicator
                    }
                    return cell
                } else {
                    assert(false, "Unknown cell type.")
                }
            }
        }
        
        assert(false, "Unknown index.")
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (sections[indexPath.section].chart == nil) {
            return createCell(item: sections[indexPath.section].data[indexPath.item], indexPath: indexPath, isSimple: true)
        } else {
            if (indexPath.item == 0) {
                if (sections[indexPath.section].sectionType == .lineChartByMonths && sections[indexPath.section].chart.data.count > 2) {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "RI_NamedLineChartTableViewCell", for: indexPath) as? NamedLineChartTableViewCell {
                        InitCellHelpers.initLineChartCell(cell: cell, chart: sections[indexPath.section].chart!)
                        return cell
                    } else {
                        assert(false, "Unknown cell type.")
                    }
                } else if (sections[indexPath.section].sectionType == .barChartByUsers || (sections[indexPath.section].sectionType == .lineChartByMonths && sections[indexPath.section].chart.data.count <= 2)) {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "RI_NamedBarChartTableViewCell", for: indexPath) as? NamedBarChartTableViewCell {
                        InitCellHelpers.initBarChartCell(cell: cell, chart: sections[indexPath.section].chart!)
                        return cell
                    } else {
                        assert(false, "Unknown cell type.")
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "RI_NamedPieTableViewCell", for: indexPath) as? NamedPieTableViewCell {
                        InitCellHelpers.initPieCell(cell: cell, chart: sections[indexPath.section].chart!)
                        return cell
                    } else {
                        assert(false, "Unknown cell type.")
                    }
                }
            } else {
                return createCell(item: sections[indexPath.section].data[indexPath.item - 1], indexPath: indexPath)
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (sections[indexPath.section].chart == nil) {
            if (sections[indexPath.section].data[indexPath.item].dataTypes.contains(StatisticDataTypes.Transaction)) {
                return true
            } else if (sections[indexPath.section].data[indexPath.item].dataTypes.contains(StatisticDataTypes.Category) && sections[indexPath.section].sectionType != SectionsTypes.total) {
                return true
            }
        } else if (indexPath.item > 0) {
            if (sections[indexPath.section].data[indexPath.item - 1].dataTypes.contains(StatisticDataTypes.Transaction)) {
                return true
            } else if (sections[indexPath.section].data[indexPath.item - 1].dataTypes.contains(StatisticDataTypes.Category) && sections[indexPath.section].sectionType != SectionsTypes.total) {
                return true
            }
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (sections[indexPath.section].chart == nil) {
                if (sections[indexPath.section].data[indexPath.item].dataTypes.contains(StatisticDataTypes.Transaction)) {
                    _ = DOTransactionDataHelper.markDelete(id: sections[indexPath.section].data[indexPath.item].transactionId!, needPost: false)
                    sections[indexPath.section].data.remove(at: indexPath.item)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else if (sections[indexPath.section].data[indexPath.item].dataTypes.contains(StatisticDataTypes.Category) ) {
                    _ = DOCategoryDataHelper.markDelete(id: sections[indexPath.section].data[indexPath.item].categoryId!, needPost: false)
                    sections[indexPath.section].data.remove(at: indexPath.item)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            } else if (indexPath.item > 0) {
                if (sections[indexPath.section].data[indexPath.item - 1].dataTypes.contains(StatisticDataTypes.Transaction)) {
                    _ = DOTransactionDataHelper.markDelete(id: sections[indexPath.section].data[indexPath.item - 1].transactionId!, needPost: false)
                    sections[indexPath.section].data.remove(at: indexPath.item - 1)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else if (sections[indexPath.section].data[indexPath.item - 1].dataTypes.contains(StatisticDataTypes.Category)) {
                    _ = DOCategoryDataHelper.markDelete(id: sections[indexPath.section].data[indexPath.item - 1].categoryId!, needPost: false)
                    sections[indexPath.section].data.remove(at: indexPath.item - 1)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
            if (sections[indexPath.section].data.count <= 0) {
                edit(sender: editButton)
            }
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var statistic: DOStatisticData!
        if (sections[indexPath.section].chart == nil) {
            statistic = sections[indexPath.section].data[indexPath.item]
        } else if (indexPath.item > 0) {
            statistic = sections[indexPath.section].data[indexPath.item - 1]
        }
        if (statistic != nil && pageViewController != nil && !statistic.isEmpty) {
            if (statistic.dataTypes == [StatisticDataTypes.Transaction]) {
                performSegue(withIdentifier: "EditTransaction", sender: statistic)
            } else if (pageViewController.statistic == nil || statistic.dataTypes != pageViewController.statistic.dataTypes) {
                let sc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StatisticPageViewController") as! StatisticPageViewController
                sc.statistic = statistic
                pageViewController.navigationController?.pushViewController(sc, animated: true)
            } else if (statistic.dataTypes == [StatisticDataTypes.Category]) {
                performSegue(withIdentifier: "EditCategory", sender: statistic)
            }
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func edit(sender: UIBarButtonItem) {
        isEditing = !isEditing
        
        if (isEditing) {
            sender.title = "Done"
        } else {
            sender.title = "Edit"
        }
        
        NotificationCenter.default.post(name: Notification.Name.FamilyBudgetDidChangeData, object: ["StatisticTableViewController", "markDelete"])
    }

    @IBAction func addCostTransaction(sender: UIBarButtonItem) {
        if (sections.count > 0) {
            performSegue(withIdentifier: "AddCostTransaction", sender: sections[0].statistic)
        } else {
            performSegue(withIdentifier: "AddCostTransaction", sender: nil)
        }
    }
    
    @IBAction func addProfitTransaction(sender: UIBarButtonItem) {
        if (sections.count > 0) {
            performSegue(withIdentifier: "AddProfitTransaction", sender: sections[0].statistic)
        } else {
            performSegue(withIdentifier: "AddProfitTransaction", sender: nil)
        }
    }
    
    @IBAction func addCostCategory(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddCostCategory", sender: nil)
    }
    
    @IBAction func addProfitCategory(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddProfitCategory", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "EditTransaction":
            print("Edit a transaction.")
            guard let nc = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let vc = nc.viewControllers[0] as? TransactionEditTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let statistic = sender as? DOStatisticData else {
                fatalError("Unexpected sender: \(segue.destination)")
            }

            vc.title = "Редактирование операции"
            vc.transationId = statistic.transactionId
        case "EditCategory":
            print("Edit a category.")
            guard let nc = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let vc = nc.viewControllers[0] as? CategoryEditTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let statistic = sender as? DOStatisticData else {
                fatalError("Unexpected sender: \(segue.destination)")
            }
            
            vc.title = "Редактирование категории"
            vc.categoryId = statistic.categoryId
        case "AddCostTransaction":
            print("Adding a new cost.")
            guard let nc = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let vc = nc.viewControllers[0] as? TransactionEditTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            let statistic = sender as? DOStatisticData
            if (statistic != nil && statistic?.categoryId != nil) {
                vc.categoryId = statistic?.categoryId
            }
            
            vc.categoryType = CategoryTypes.Cost
            vc.title = "Новый расход"
        case "AddProfitTransaction":
            print("Adding a new profit.")
            guard let nc = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let vc = nc.viewControllers[0] as? TransactionEditTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            let statistic = sender as? DOStatisticData
            if (statistic != nil && statistic?.categoryId != nil) {
                vc.categoryId = statistic?.categoryId
            }

            vc.categoryType = CategoryTypes.Profit
            vc.title = "Новый доход"
        case "AddCostCategory":
            print("Adding a new cost.")
            guard let nc = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let vc = nc.viewControllers[0] as? CategoryEditTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            vc.title = "Новая категория расхода"
            
            vc.category = DOCategory(categoryId: 0, userId: SQLiteDataStore.sharedInstance.currentUser.userId, categoryTitle: "", categoryType: CategoryTypes.Cost, categoryUploaded: 0, categoryDeleted: 0)
        case "AddProfitCategory":
            print("Adding a new profit.")
            guard let nc = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let vc = nc.viewControllers[0] as? CategoryEditTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            vc.title = "Новая категория дохода"
            
            vc.category = DOCategory(categoryId: 0, userId: SQLiteDataStore.sharedInstance.currentUser.userId, categoryTitle: "", categoryType: CategoryTypes.Profit, categoryUploaded: 0, categoryDeleted: 0)
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
}
