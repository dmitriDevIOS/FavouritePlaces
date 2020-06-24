//
//  MapManager.swift
//  FavouritePlaces
//
//  Created by Dmitrii Timofeev on 07/04/2020.
//  Copyright © 2020 Dmitrii Timofeev. All rights reserved.
//

import UIKit
import MapKit


class MapManager {
    
    let locationManager = CLLocationManager()
    
    private let regionInMeters = 1000.00
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D? // координаты места
    

    
    // MARK: Отображение маркера заведения на карте
    
     func setupPlacemark(place: Place, myMapView: MKMapView) {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {return} // - CLPlacemark что это???
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation() // - используется для того чтобы описать какую-то точку на карте
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            
            myMapView.showAnnotations([annotation], animated: true )
            myMapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    
    // Проверка доступности сервисов геолокации
    
    func checkLocationServices(myMapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(myMapView: myMapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disabled", message: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
        }
        
    }
    
    // проверка авторизации приложения для использования сервисов геолокации
    
    func checkLocationAuthorization(myMapView: MKMapView, segueIdentifier: String) {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse :
            myMapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(myMapView: myMapView) }
            break
        case .denied :
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your location is not available", message: "Enable it in settings")
            }
            break
        case .notDetermined :
            locationManager.requestWhenInUseAuthorization()
        case .restricted :
            
            break
        case .authorizedAlways :
            break
            
        @unknown default:
            print("new case is available")
        }
        
    }
    
    
    // фокус карты на местоположении пользователя
    
    func showUserLocation(myMapView: MKMapView) {
        // если удалось определить локацию
        if let location = locationManager.location?.coordinate {
            
            // определяем регион расположения на карте
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            myMapView.setRegion(region, animated: true)
        }
    }
    
    // строим маршрут от местоположения пользователя до заведения
    
    func getDirection(for myMapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        // 1. определяем местоположение пользователя, локация может быть не определена, поэтому это опционал, поэтому мы извлекаем его с помощью guard
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation() // включаем режим постоянного отслеживания пользователя, включаем только после того как местоположение было уже определенно ( как выше )
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        // если все прошло успешно - создаем маршрут
        let directions = MKDirections(request: request)
        
        resetMapView(withNew: directions, myMapView: myMapView)
        // запускаем рассчет маршрута, calculate метод возвращает маршрут со всеми данными
        directions.calculate { ( response , error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let response = response else {
                
                self.showAlert(title: "Direction(s) are not available", message: "Cannot determine direction(s)")
                return
            }
            
            // обьект response содержит в себе массив с маршрутами
            for route in response.routes {
                myMapView.addOverlay(route.polyline) // polyline - содержит геометрию всего маршрута
                // фокусируем карту таким образом чтобы весь маршрут был виден целиком
                myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                // теперь поработаем с данными такими как расстояние (определяется в метрах) и время в пути ( в секундах )
                let distance = String(format: "%.1f", route.distance / 1000 ) // "%.1f" - округляем до десятых
                let timeInterval =  String(format: "%.1f", route.expectedTravelTime / 60)
                
                print("Distance to your destination is \(distance)km.")
                print("Time to spend: \(timeInterval) minutes.")
            }
        }
    }
    
    
    // настройка запроса для построения маршрута, запрос мы будем возвращать опциональный так как не факт что мы его получим
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil } // мы не можем просто так выйти из метода так как метод должен вернуть что-то, поэтому мы возвращаем nil
        let statingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        // теперь когда у нас есть две точки на карте мы можем попробовать построить маршрут
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: statingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
        
    }
    
    
    //  Меняем отображаемую зону области карты в соответствии с перемещением пользователя
    
    func startTrackingUserLocation(for myMapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return } // убеждаемся что previousLocation не равно nil
        let center = getCenterLocation(for: myMapView) // опеделяем текущие координаты центра отображаемой области
        guard center.distance(from: location) > 50 else { return } // если дистанция больше 50 метров
        
        closure(center)
        
    }
    
    // Сброс всех ранее построеныных маршрутов перед построением нового
    
    func resetMapView(withNew directions: MKDirections, myMapView: MKMapView) {
        
        myMapView.removeOverlays(myMapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    // Определение центра отображаемой области карты
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
        
    }
    
    
    
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(actionOK)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        // определяем позиционирование данного окна относительно других окон, определим его поверх всех остальных окон
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated:  true, completion: nil)
        
    }
    
    
    
}
