//
//  ListTableViewCell.swift
//  LocateStarbucks
//
//  Created by Erick Quintanar on 4/29/17.
//  Copyright © 2017 equintanart. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var ratingData:   UILabel!
    @IBOutlet weak var openNowData:  UILabel!
    @IBOutlet weak var vicinityData: UILabel!
    @IBOutlet weak var ratingStars:  UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
