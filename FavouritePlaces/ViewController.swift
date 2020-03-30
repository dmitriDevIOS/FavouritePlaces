//
//  ViewController.swift
//  FavouritePlaces
//
//  Created by Dmitrii Timofeev on 30/03/2020.
//  Copyright © 2020 Dmitrii Timofeev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    let restaurantNames = ["Cool Food", "Mandarin", "Shokolad", "Fontan", "InWine", "In White"]
    let imageNames = ["one", "two", "three", "four", "five", "six"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    
    
    
    //MARK: - Table View data source
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = restaurantNames[indexPath.row]
      
        cell.imageView?.image = UIImage(named: imageNames[indexPath.row])
        
        return cell
    }
    


}

