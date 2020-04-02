//
//  NewPlaceViewController.swift
//  FavouritePlaces
//
//  Created by Dmitrii Timofeev on 30/03/2020.
//  Copyright © 2020 Dmitrii Timofeev. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var isChangeImage = false
    
    @IBOutlet weak var placeTypeTextField: UITextField!
    @IBOutlet weak var placeLocationTextfield: UITextField!
    @IBOutlet weak var placeNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var ratingControll: RatingControll!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        saveButton.isEnabled = false
        placeNameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()

    }
    
    
    func savePlace() {
        
        let image : UIImage?
        
        if  isChangeImage {
            image = imageOfPlace.image
        } else {
            image = UIImage(named: "nonoimage")!
        }

        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeNameTextField.text!, location: placeLocationTextfield.text, type: placeTypeTextField.text, imageData: imageData, rating: Double(ratingControll.rating))
        
        
        if currentPlace != nil {
            try! realm.write {
                
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
             StorageManager.saveObject(newPlace)
        }
           
    }
    
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupEditScreen() {
        
        if currentPlace != nil {
            
            setupNavigationBar()
            isChangeImage = true 
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}
            imageOfPlace.image = image
            imageOfPlace.contentMode  = .scaleAspectFill
            placeNameTextField.text  = currentPlace?.name
            placeLocationTextfield.text = currentPlace?.location
            placeTypeTextField.text = currentPlace?.type
            ratingControll.rating = Int(currentPlace.rating)
        }
        
    }
    
    private func setupNavigationBar() {
        
        if let topItem = navigationController?.navigationBar.topItem {
            
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // убираем название кнопки назад
            
        }
        
        navigationItem.leftBarButtonItem = nil // прячет кнопку cancel и дает возможность делать навигацию обратно
        title = currentPlace?.name
        saveButton.isEnabled = true
        
    }
    
    
}







//MARK: - TABLE view delegate

extension NewPlaceViewController  {
    
    // close keyboard when tapping at any row except first one
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let cameraItem = UIImage(systemName: "camera")
            let photoItem = UIImage(systemName: "photo")
        
            
            let actionSheet = UIAlertController(title: nil , message: "Chosee any way to add a photo!", preferredStyle: .actionSheet)
            
            let actionCamera = UIAlertAction(title: "Camera", style: .default) { (_) in
                // TODO: choose image picker
                self.chooseImagePicker(source: .camera)
            }
            actionCamera.setValue(cameraItem, forKey: "image")
            actionCamera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            
            let actionPhoto = UIAlertAction(title: "Photo", style: .default) { (_) in
                // TODO: choose image picker
                self.chooseImagePicker(source: .photoLibrary)
            }
            actionPhoto.setValue(photoItem, forKey: "image")
            actionPhoto.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            actionSheet.addAction(actionPhoto)
            actionSheet.addAction(actionCamera)
            actionSheet.addAction(actionCancel)
            present(actionSheet, animated: true, completion: nil )
            
        } else {
            view.endEditing(true)
        }
        
    }
    
}


//MARK: - TextField delegate

extension NewPlaceViewController : UITextFieldDelegate {
    
    // close keyboard when pressing done button
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - textField changed

    @objc private func textFieldChanged() {
        
        if placeNameTextField.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
        
    }
    
    
}


//MARK: - Work with image

extension NewPlaceViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self // делегируем передачу изображения
            imagePicker.allowsEditing = true // allows editing a choosen photo
            imagePicker.sourceType = source
            present(imagePicker, animated: true, completion: nil )
            
        }
    }
    
    // Picking the selected image
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageOfPlace.image = info[.editedImage] as? UIImage
        imageOfPlace.contentMode = .scaleAspectFill
        imageOfPlace.clipsToBounds = true
        isChangeImage = true
        dismiss(animated: true, completion: nil)
        
        
        
    }
    
}
