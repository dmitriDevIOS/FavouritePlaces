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
    
    @IBOutlet weak var myImage: UIImageView! {
        didSet{
            myImage.layer.cornerRadius = myImage.frame.height / 2
            myImage.contentMode = .scaleAspectFill
            myImage.clipsToBounds = true
        }
    }
    
    
    @IBOutlet weak var cosmosView: CosmosView! {
        
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
