//
//  TodayViewController.swift
//  widget
//
//  Created by Dmitry Rybochkin on 15.03.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Alamofire
import Charts
import NotificationCenter
import SwiftyJSON
import UIKit

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var profitAmountLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var costAmountLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var loader: UIActivityIndicatorView!

    var timer: Timer! = nil
    var widget: DOWidget! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.

        let userDefaul = UserDefaults(suiteName: "group.FamilyBudget")
        if let accessToken = userDefaul?.string(forKey: "accessToken") {
            SQLiteDataStore.sharedInstance.currentUser.userAccessToken = accessToken
        }
        if let userId = userDefaul?.integer(forKey: "userId") {
            SQLiteDataStore.sharedInstance.currentUser.userId = Int64(userId)
        }
        if let lastTick = userDefaul?.integer(forKey: "lastTick") {
            SQLiteDataStore.sharedInstance.options.lastTick = Int64(lastTick)
        }

        updateWidget(DOWidget(cost: 0.0, profit: 0.0, balance: 0.0, date: Int64(Date().timeIntervalSince1970), count: 0))

        timer = Timer(timeInterval: 10, repeats: true, block: { (_: Timer) in
            if (SQLiteDataStore.sharedInstance.currentUser.userAccessToken != "") {
                self.loader.startAnimating()
                ServerImplementation.sharedInstance.getWidgetData(callback: self.updateWidget)
            }
        })
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        timer.fire()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        if (SQLiteDataStore.sharedInstance.currentUser.userAccessToken != "") {
            self.loader.startAnimating()
            ServerImplementation.sharedInstance.getWidgetData(callback: { (_: DOWidget?) in
                completionHandler(NCUpdateResult.newData)
            })
        } else {
            completionHandler(NCUpdateResult.newData)
        }
    }

    func updateWidget(_ widget: DOWidget?) {
        if (widget != nil && (self.widget == nil || widget?.cost != self.widget.cost || widget?.profit != self.widget.profit || widget?.count != self.widget?.count || widget?.date != self.widget.date)) {
            titleLabel.text = String(format: "%@ %@", (widget?.date.date().toStringWith(format: "MMMM, YYYY"))!, Date().toStringWith(format: "HH:mm:ss"))
            totalAmountLabel.text = widget?.balance.toStringWith(locale: "ru_RU", andPrefix: "-")
            costAmountLabel.text = widget?.cost.toStringWith(locale: "ru_RU", andPrefix: "-")
            profitAmountLabel.text = widget?.profit.toStringWith(locale: "ru_RU", andPrefix: "-")
            updatePieChart(widget!)
            self.widget = widget
        } else {
            titleLabel.text = String(format: "%@ %@", Date().toStringWith(format: "MMMM, YYYY"), Date().toStringWith(format: "HH:mm:ss"))
        }
        self.loader.stopAnimating()
    }

    func updatePieChart(_ widget: DOWidget) {
        pieChartView.noDataText = "no data"

        pieChartView.legend.drawInside = true
        pieChartView.legend.enabled = false
        pieChartView.drawHoleEnabled = false
        pieChartView.chartDescription?.enabled = false

        let chartDataSet = PieChartDataSet(values: [PieChartDataEntry(value: abs(widget.cost.doubleValue), label: "Расходы"), PieChartDataEntry(value: abs(widget.profit.doubleValue), label: "Доходы")], label: ".")
        chartDataSet.valueFormatter = AmountValueFormater()
        chartDataSet.colors = [UIColor.red, UIColor.green]
        pieChartView.data = PieChartData(dataSets: [chartDataSet])
        pieChartView.animate(xAxisDuration: 5.4, easingOption: ChartEasingOption.easeOutBack)
    }
}
