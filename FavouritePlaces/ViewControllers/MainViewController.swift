//
//  ViewController.swift
//  FavouritePlaces
//
//  Created by Dmitrii Timofeev on 30/03/2020.
//  Copyright © 2020 Dmitrii Timofeev. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    //MARK: Properties
    
    private var filteredPlaces: Results<Place>!
    private var placesArray: Results<Place>! // Results - это автообновляемый тип контейнера который возвращает запрашеваемые обьекты, результаты всегда отбражают текущее состояние хранилища в текущем потоке.
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text  else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil) // передавая сюда nil мы хотим сообщить, что для отображения результата поиска мы хотим использовать тот же view в котором отображается контент. Для этого сам класс ViewController должен быть подписан под протокол UISearchResultsUpdating
    
    //MARK: Outlets
    
    @IBOutlet weak var mySortingBarButtomItem: UIBarButtonItem!
    @IBOutlet weak var mySegmentedControll: UISegmentedControl!
    @IBOutlet weak var myTableView: UITableView!
    
   
    //MARK: --------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesArray = realm.objects(Place.self)
        
        
        
        // setup search controller
        
        searchController.searchResultsUpdater = self // получателем информации об изменении текста должен быть наш класс (ViewController)
        searchController.obscuresBackgroundDuringPresentation = false // - по умолчанию вью с результатами поиска НЕ позволяет взаимодействовать с отображаемым контентом и если отключить этот параметр то это позволит взаимодействовать с этим вью как с основным
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
        definesPresentationContext = true // позволяет отпустить строку поиска при переходе на другой екран
        
        
    }
    
    
    @IBAction func sortSelectionSegmentControll(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reverseSorting(_ sender: UIBarButtonItem) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting {
            mySortingBarButtomItem.image = UIImage(systemName: "arrow.up.arrow.down.square")
        } else {
            mySortingBarButtomItem.image = UIImage(systemName: "arrow.up.arrow.down.square.fill")
        }
        sorting()
    }
    
    
    private func sorting() {
        
        if mySegmentedControll.selectedSegmentIndex == 0 {
            placesArray = placesArray.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            placesArray = placesArray.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        myTableView.reloadData()
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else {return}
        newPlaceVC.savePlace()
        myTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "showDetail" {
            
            guard let indexPath = myTableView.indexPathForSelectedRow else {return} // определяем индекс ячейки по которой нажимаем
            
            
            let place = isFiltering ? filteredPlaces[indexPath.row] : placesArray[indexPath.row]
                   
            
            let vc = segue.destination as! NewPlaceViewController
            vc.currentPlace = place 
            
        }
    }
}


extension MainViewController : UITableViewDelegate, UITableViewDataSource  {
    
    //MARK: - Table View data source
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredPlaces.count
        }
        
        return placesArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell


            
        let place = isFiltering ? filteredPlaces[indexPath.row] : placesArray[indexPath.row]
        
        
        
        cell.myLabelName.text = place.name
        cell.myLabelLocation.text = place.location
        cell.myLabelType.text = place.type
        cell.myImage.image = UIImage(data: place.imageData!)

        cell.cosmosView.rating = place.rating
        
        return cell
    }
    
    
    //MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = placesArray[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Deleting") { (_, _) in
            
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
        return [deleteAction]
        
    }
    
    
}

extension MainViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
        filteredPlaces = placesArray.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        myTableView.reloadData()
        
    }
    
}
