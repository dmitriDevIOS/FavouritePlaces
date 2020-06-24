//
//  MapViewController.swift
//  FavouritePlaces
//
//  Created by Dmitrii Timofeev on 04/04/2020.
//  Copyright © 2020 Dmitrii Timofeev. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


// Протокол

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?) //  - нужно имплементировать
    // @objc optional func getAddress(_ address: String)  // - можно имплементировать, а можно нет. но тогда протокол тоже нужно записать как @objc
}


class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControllerDelegate : MapViewControllerDelegate?
    var place =  Place()
    
    
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifier = ""
    
    
    // ПОЧИТАЙ ЕЩЕ РАЗ ЧТО ТАКОЕ DID SET
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: myMapView, and: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(myMapView: self.myMapView)
                }
            }
        }
    }
    
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var myPinOnMap: UIImageView!
    @IBOutlet weak var myLabelCurrentAddress: UILabel!
    @IBOutlet weak var myButtonDone: UIButton!
    @IBOutlet weak var directionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMapView.delegate = self
        setupMapView()
   
        
    }
    
    
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        mapViewControllerDelegate?.getAddress(myLabelCurrentAddress.text)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func userLocationButtonPressed(_ sender: UIButton) {
        mapManager.showUserLocation(myMapView: myMapView)
    }
    
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func directionButtonPressed(_ sender: UIButton) {
        mapManager.getDirection(for: myMapView) { (location) in
            self.previousLocation = location
        }
    }
    
    
    
    private func setupMapView() {
        
        directionButton.isHidden = true
        
        mapManager.checkLocationServices(myMapView: myMapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        
        if incomeSegueIdentifier == "showMap" {
            mapManager.setupPlacemark(place: place, myMapView: myMapView)
            myPinOnMap.isHidden = true
            myLabelCurrentAddress.isHidden = true
            myButtonDone.isHidden = true
            directionButton.isHidden = false
        }

    }
    

}


extension MapViewController : MKMapViewDelegate { // предоставляет более гипкую настройку, так же нужно назначить делегата
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil } // проверяем чтобы аннотация не была позицией юзера, а любой другой анотацией
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        // в том случае если на карте не окажиться не одного представления с аннотацией, которую мы могли бы переиспользовать. то мы будем инициализировать этот обьект новым значением обьекта класса MKAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            //для того чтобы отобразить анотацию в виде банера нужно присвоить true
            annotationView?.canShowCallout = true
        }
    
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }

        return annotationView
    }
    
    
    
    // данный метод вызывается каждый раз при смене отображаемого региона
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = mapManager.getCenterLocation(for: myMapView)
        let geocoder = CLGeocoder()
        
        
        if incomeSegueIdentifier == "showMap" && previousLocation != nil {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.mapManager.showUserLocation(myMapView: self.myMapView)
            }
        }
        
        geocoder.cancelGeocode() // освобождаем ресурсы связаные с геокодированием
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let houseNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                
                if streetName != nil && houseNumber != nil {
                    self.myLabelCurrentAddress.text = "\(streetName!), \(houseNumber!)"
                } else if streetName != nil {
                    self.myLabelCurrentAddress.text = "\(streetName!)"
                } else {
                    self.myLabelCurrentAddress.text = "Cannot determine location"
                }
            }
        }
    }
    
    // цвет отображения пути так как наложение на карту по умолчанию идет НЕВИДЕМЫМ
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let rendered = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        rendered.strokeColor = .green
        
        return rendered
        
    }
}

extension MapViewController : CLLocationManagerDelegate {
   
    // вызывается при каждом изменении статуса авторизации нашего приложения для использования служб геолокации
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAuthorization(myMapView: myMapView, segueIdentifier: incomeSegueIdentifier)
    }
    
}
