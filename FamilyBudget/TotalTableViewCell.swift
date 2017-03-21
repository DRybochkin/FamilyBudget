//
//  TotalTableViewCell.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 13.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit

class TotalTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var costValue: UILabel!
    @IBOutlet weak var profitValue: UILabel!
    @IBOutlet weak var totalValue: UILabel!

    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setSelected(highlighted, animated: animated)

    }
}
