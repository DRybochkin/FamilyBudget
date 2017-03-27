//
//  CreateCellHelpers.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import Charts
import Foundation
import UIKit

class InitCellHelpers {
    //InitializeCells
    static func initTotalCell(cell: TotalTableViewCell!, statistic: DOStatisticData) {
        if (cell != nil) {
            cell.cellTitle.text = statistic.title
            cell.costValue.text = statistic.dataCost.toStringWith(locale: "ru_RU", andPrefix: "-")
            cell.costValue.textColor = UIColor.red
            cell.costLabel.textColor = UIColor.red
            cell.profitValue.textColor = UIColor.green
            cell.profitLabel.textColor = UIColor.green
            cell.profitValue.text = statistic.dataProfit.toStringWith(locale: "ru_RU")
            if ((statistic.dataProfit.doubleValue - statistic.dataCost.doubleValue) >= 0) {
                cell.totalLabel.textColor = UIColor.green
                cell.totalValue.textColor = UIColor.green
            } else {
                cell.totalLabel.textColor = UIColor.red
                cell.totalValue.textColor = UIColor.red
            }
            cell.totalValue.text = NSNumber(value: (statistic.dataProfit.doubleValue - statistic.dataCost.doubleValue)).toStringWith(locale: "ru_RU")
        }
    }

    static func initTransactionCell(cell: TransactionTableViewCell!, statistic: DOStatisticData) {
        if (cell != nil) {
            cell.transactionDate.text = statistic.transactionDueDate?.date().toStringWith(format: "dd MMMM, YYYY hh:mm")
            if (statistic.categoryType == CategoryTypes.cost) {
                cell.transactionAmount.text = statistic.dataCost.toStringWith(locale: "ru_RU", andPrefix: "-")
                cell.transactionAmount.textColor = UIColor.red
            } else {
                cell.transactionAmount.text = statistic.dataProfit.toStringWith(locale: "ru_RU")
                cell.transactionAmount.textColor = UIColor.green
            }
            cell.transactionUser.text = statistic.userTitle
            cell.transactionCategory.text = String(format: "%@ %@", statistic.categoryTitle!, statistic.transactionDescription!)
            cell.accessoryType = .disclosureIndicator
        }
    }

    static func initSimpleCell(cell: SimpleTableViewCell!, statistic: DOStatisticData) {
        if (cell != nil) {
            cell.cellTitle.text = statistic.title

            let amount: NSNumber = NSNumber(value: statistic.dataProfit.floatValue - statistic.dataCost.floatValue)
            cell.cellAmount.text = amount.toStringWith(locale: "ru_RU", andPrefix: "-")
            if (amount.doubleValue >= 0) {
                cell.cellAmount.textColor = UIColor.green
            } else {
                cell.cellAmount.textColor = UIColor.red
            }
        }
    }

    static func initColoredCell(cell: ColoredImageTableViewCell!, statistic: DOStatisticData) {
        if (cell != nil) {
            cell.cellImage.image? = (cell.cellImage.image?.withRenderingMode(.alwaysTemplate))!
            cell.cellImage.tintColor = statistic.color

            cell.cellTitle.text = statistic.title

            if (statistic.categoryType == CategoryTypes.cost) {
                cell.cellAmount?.text = statistic.dataCost.toStringWith(locale: "ru_RU")
            } else if (statistic.categoryType == CategoryTypes.profit) {
                cell.cellAmount?.text = statistic.dataProfit.toStringWith(locale: "ru_RU")
            } else {
                cell.cellAmount?.text = NSNumber(value: statistic.dataProfit.doubleValue - statistic.dataCost.doubleValue).toStringWith(locale: "ru_RU")
            }
        }
    }

    static func initPieCell(cell: NamedPieTableViewCell!, chart: DOChart!) {
        if (cell != nil) {
            cell.cellChart.noDataText = "no data"

            if (!chart.data.isEmpty) {
                let find = chart.data.filter { el in !el.isEmpty }
                cell.cellChart.legend.drawInside = true
                cell.cellChart.legend.enabled = false

                var dataEntries: [PieChartDataEntry] = []
                var colors: [UIColor] = []
                for i in 0 ..< chart.data.count where find.isEmpty || !chart.data[i].isEmpty {
                    let item: DOStatisticData = chart.data[i]
                    var value = 0.0
                    if (item.categoryType == CategoryTypes.cost) {
                        value = item.dataCost.doubleValue
                    } else if (item.categoryType == CategoryTypes.profit) {
                        value = item.dataProfit.doubleValue
                    } else {
                        value = item.dataProfit.doubleValue - item.dataCost.doubleValue
                    }
                    let dataEntry = PieChartDataEntry(value: value, label: item.title)
                    colors.append(item.color!)
                    dataEntries.append(dataEntry)
                }

                let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
                chartDataSet.valueFormatter = AmountValueFormater()
                chartDataSet.colors = colors
                let chartData = PieChartData(dataSets: [chartDataSet])
                cell.cellChart.data = chartData
                cell.cellChart.animate(xAxisDuration: 5.4, easingOption: ChartEasingOption.easeOutBack)
                cell.cellChart.chartDescription?.enabled = false
            } else {
                cell.cellChart.data = nil
            }
        }
    }

    static func initLineChartCell(cell: NamedLineChartTableViewCell!, chart: DOChart!) {
        if (cell != nil) {
            cell.cellChart.noDataText = "no data"

            if (!chart.data.isEmpty) {
                cell.cellChart.chartDescription?.enabled = false
                cell.cellChart.dragEnabled = false
                cell.cellChart.setScaleEnabled(false)

                let l: Legend = cell.cellChart.legend
                l.horizontalAlignment = Legend.HorizontalAlignment.right
                l.verticalAlignment = Legend.VerticalAlignment.top
                l.orientation = Legend.Orientation.vertical
                l.drawInside = true
                //l.textColor = UIColor.white

                let xAxis: XAxis = cell.cellChart.xAxis
                xAxis.labelPosition = XAxis.LabelPosition.bottom
                xAxis.labelRotationAngle = -90.0
                xAxis.wordWrapEnabled = true
                xAxis.labelTextColor = UIColor.white
                xAxis.drawGridLinesEnabled = false
                xAxis.granularity = 1.0 / 12.0
                xAxis.axisMinimum = Date().dateDouble()
                xAxis.axisMaximum = 0.0
                xAxis.valueFormatter = DateValueFormater()

                let yAxis: YAxis = cell.cellChart.leftAxis
                yAxis.labelPosition = YAxis.LabelPosition.outsideChart
                //yAxis.labelTextColor = UIColor.white
                yAxis.drawGridLinesEnabled = false
                yAxis.axisMinimum = 0.0
                yAxis.axisMaximum = 0.0

                cell.cellChart.legend.form = Legend.Form.line

                var dataSets: [LineChartDataSet] = []

                var costValues: [ChartDataEntry] = []
                var profitValues: [ChartDataEntry] = []

                for j in 0 ..< chart.data.count {
                    let dateId = chart.data[j].date?.dateDouble()

                    if (chart.categoryType == CategoryTypes.cost || chart.categoryType == CategoryTypes.all) {
                        let amountCost = chart.data[j].dataCost.doubleValue
                        costValues.append(ChartDataEntry(x: dateId!, y: chart.data[j].dataCost.doubleValue))
                        if (amountCost > yAxis.axisMaximum) {
                            yAxis.axisMaximum = amountCost
                        }
                    }

                    if (chart.categoryType == CategoryTypes.profit || chart.categoryType == CategoryTypes.all) {
                        let amountProfit = chart.data[j].dataProfit.doubleValue
                        profitValues.append(ChartDataEntry(x: dateId!, y: chart.data[j].dataProfit.doubleValue))
                        if (amountProfit > yAxis.axisMaximum) {
                            yAxis.axisMaximum = amountProfit
                        }
                    }

                    if (dateId! > xAxis.axisMaximum) {
                        xAxis.axisMaximum = dateId!
                    }
                    if (dateId! < xAxis.axisMinimum) {
                        xAxis.axisMinimum = dateId!
                    }
                }
                if (chart.categoryType == CategoryTypes.cost || chart.categoryType == CategoryTypes.all) {
                    let d: LineChartDataSet = LineChartDataSet(values: costValues, label: "Расходы")
                    //d.valueTextColor = UIColor.white
                    d.axisDependency = YAxis.AxisDependency.left
                    d.mode = LineChartDataSet.Mode.cubicBezier
                    d.drawValuesEnabled = true
                    d.lineWidth = 2.5
                    d.circleRadius = 4.0
                    d.circleHoleRadius = 2.0
                    d.setCircleColor(chart.circleColors![0])
                    d.setColor(chart.colors![0])
                    d.valueFormatter = AmountValueFormater()
                    dataSets.append(d)
                }

                if (chart.categoryType == CategoryTypes.profit || chart.categoryType == CategoryTypes.all) {
                    let d = LineChartDataSet(values: profitValues, label: "Доходы")
                    //d.valueTextColor = UIColor.white
                    d.axisDependency = YAxis.AxisDependency.left
                    d.mode = LineChartDataSet.Mode.cubicBezier
                    d.drawValuesEnabled = true
                    d.lineWidth = 2.5
                    d.circleRadius = 4.0
                    d.circleHoleRadius = 2.0
                    d.setCircleColor(chart.circleColors![1])
                    d.setColor(chart.colors![1])
                    d.valueFormatter = AmountValueFormater()
                    dataSets.append(d)
                }

                xAxis.axisMinimum -= 0.1 / 12.0
                xAxis.axisMaximum += 0.1 / 12.0
                yAxis.axisMaximum *= 1.1

                cell.cellChart.leftAxis.enabled = true
                cell.cellChart.rightAxis.enabled = false

                cell.cellChart.data = LineChartData(dataSets: dataSets)
                cell.cellChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutBack)
            } else {
                cell.cellChart.data = nil
            }
        }
    }

    static func initBarChartCell(cell: NamedBarChartTableViewCell!, chart: DOChart!) {
        if (cell != nil) {
            cell.chartView.noDataText = "no data"

            if (!chart.data.isEmpty) {
                cell.chartView.chartDescription?.enabled = false
                let legend = cell.chartView.legend
                legend.enabled = true
                legend.horizontalAlignment = .right
                legend.verticalAlignment = .top
                legend.orientation = .vertical
                legend.drawInside = true
                legend.yOffset = 10.0
                legend.xOffset = 10.0
                legend.yEntrySpace = 0.0

                let xaxis = cell.chartView.xAxis
                xaxis.drawGridLinesEnabled = true
                xaxis.labelPosition = .bottom
                xaxis.granularity = 1

                let yaxis = cell.chartView.leftAxis
                yaxis.spaceTop = 0.35
                yaxis.axisMinimum = 0
                yaxis.drawGridLinesEnabled = false
                cell.chartView.rightAxis.enabled = false

                var costs: [BarChartDataEntry] = []
                var profits: [BarChartDataEntry] = []
                var titles: [String] = []
                for i in 0..<chart.data.count {
                    let costEntry = BarChartDataEntry(x: Double(i), y: chart.data[i].dataCost.doubleValue)
                    costs.append(costEntry)
                    let profitEntry = BarChartDataEntry(x: Double(i), y: chart.data[i].dataProfit.doubleValue)
                    profits.append(profitEntry)
                    titles.append(chart.data[i].title)
                }

                xaxis.valueFormatter = IndexAxisValueFormatter(values: titles)

                let chartDataSetCost = BarChartDataSet(values: costs, label: "Расходы")
                chartDataSetCost.valueFormatter = AmountValueFormater()
                let chartDataSetProfit = BarChartDataSet(values: profits, label: "Доходы")
                chartDataSetProfit.valueFormatter = AmountValueFormater()

                let dataSets: [BarChartDataSet]!
                if (chart.data[0].dataTypes.contains(StatisticDataTypes.category)) {
                    if (chart.data[0].categoryType == CategoryTypes.cost) {
                        dataSets = [chartDataSetCost]
                    } else {
                        dataSets = [chartDataSetProfit]
                    }
                } else {
                    dataSets = [chartDataSetCost, chartDataSetProfit]
                }

                chartDataSetCost.colors = [UIColor.red]
                chartDataSetProfit.colors = [UIColor.green]

                let chartData = BarChartData(dataSets: dataSets)

                let barWidth = Double(0.3)
                chartData.barWidth = barWidth
                if (!chart.data[0].dataTypes.contains(StatisticDataTypes.category)) {
                    xaxis.centerAxisLabelsEnabled = true
                    let groupSpace = 0.3
                    let barSpace = 0.05

                    let groupCount = titles.count
                    let startItem = 0

                    cell.chartView.xAxis.axisMinimum = Double(startItem)
                    let groupWidth = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
                    cell.chartView.xAxis.axisMaximum = Double(startItem) + groupWidth * Double(groupCount)

                    chartData.groupBars(fromX: Double(startItem), groupSpace: groupSpace, barSpace: barSpace)
                } else {
                    cell.chartView.xAxis.axisMinimum = Double(0)
                    cell.chartView.xAxis.axisMaximum = Double(0)
                }
                cell.chartView.notifyDataSetChanged()

                cell.chartView.data = chartData

                cell.chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
            } else {
                cell.chartView.data = nil
            }
        }
    }
}
