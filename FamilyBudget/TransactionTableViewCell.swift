//
//  TransactionTableViewCell.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 02.02.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var transactionDate: UILabel!
    @IBOutlet weak var transactionAmount: UILabel!
    @IBOutlet weak var transactionUser: UILabel!
    @IBOutlet weak var transactionCategory: UILabel!

    var statistic: DOStatisticData?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
