//
//  StorageManager.swift
//  FavouritePlaces
//
//  Created by Dmitrii Timofeev on 31/03/2020.
//  Copyright © 2020 Dmitrii Timofeev. All rights reserved.
//

import RealmSwift

let realm = try! Realm()


class StorageManager {
    
    static func saveObject(_ place: Place) {
        
        try! realm.write {
            realm.add(place)
        }     
    }
    
    
    static func deleteObject(_ place: Place) {
        
        try! realm.write {
            realm.delete(place)
        }
        
    }
    
    
}
