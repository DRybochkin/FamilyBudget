//
//  NamedPieTableViewCell.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 13.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit
import Charts

class NamedPieTableViewCell: UITableViewCell {
    @IBOutlet weak var cellChart: PieChartView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
