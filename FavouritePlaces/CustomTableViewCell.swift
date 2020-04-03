//
//  CustomTableViewCell.swift
//  FavouritePlaces
//
//  Created by Dmitrii Timofeev on 30/03/2020.
//  Copyright © 2020 Dmitrii Timofeev. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {


    @IBOutlet weak var myLabelType: UILabel!
    @IBOutlet weak var myLabelLocation: UILabel!
    @IBOutlet weak var myLabelName: UILabel!
    @IBOutlet weak var myImage: UIImageView!
    
    
    @IBOutlet weak var cosmosView: CosmosView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
