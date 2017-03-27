//
//  SelectCategoryTableViewCell.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 07.02.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit

class SelectCategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var editButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
