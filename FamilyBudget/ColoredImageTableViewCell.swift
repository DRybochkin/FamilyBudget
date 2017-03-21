//
//  ColoredImageTableViewCell.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 13.01.17.
//  Copyright © 2017 Dmitry Rybochkin. All rights reserved.
//

import UIKit

class ColoredImageTableViewCell: UITableViewCell {
    @IBOutlet weak var cellAmount: UILabel!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
