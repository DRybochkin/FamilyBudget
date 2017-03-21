//
//  NamedBarChartTableViewCell.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 25.02.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit
import Charts

class NamedBarChartTableViewCell: UITableViewCell {
    @IBOutlet weak var chartView: BarChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
