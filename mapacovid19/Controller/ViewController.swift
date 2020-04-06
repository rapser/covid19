//
//  ViewController.swift
//  mapacovid19
//
//  Created by miguel tomairo on 4/3/20.
//  Copyright © 2020 rapser. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var updateButton: UIBarButtonItem!
    
    var lugares = [Covid]()
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var zoomLevel: Float = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Coronavirus Peru"
        
        locationManager?.requestAlwaysAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.distanceFilter = 50
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = self
        
        if let aux = loadJson() {
            lugares = aux
            showCurrentLocationOnMap()
        }
    }

    func setup(){
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: zoomLevel)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.mapView.addSubview(mapView)
        self.mapView.delegate = self

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }
    
    @IBAction func updateMarksTapped(_ sender: Any) {
        showSimpleAlert()
    }
    
    func showCurrentLocationOnMap(){
        
        let camera = GMSCameraPosition.camera(withLatitude: -12.1704852, longitude: -76.9628504, zoom: 13.0)
//        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        
        mapView.camera = camera
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self

//        self.mapView.addSubview(mapView)

        for data in lugares{
            let location = CLLocationCoordinate2D(latitude: data.lat, longitude: data.lon)
            print("location: \(location)")
            let marker = GMSMarker()
            marker.position = location
//                marker.snippet = data.name!
            marker.map = mapView
        }
    }
    
    func loadJson() -> [Covid]? {
        
        var response = [Covid]()
        
        if let url = Bundle.main.url(forResource: "covid", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([Covid].self, from: data)
                
                for item in jsonData {
                    response.append(item)
                }
                
                return response
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    func showSimpleAlert() {
        let alert = UIAlertController(title: "Covid19", message: "En construcción ...",         preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Salir",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                        //Sign out action
        }))
        self.present(alert, animated: true, completion: nil)
    }

}

extension ViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        print(marker.position.latitude)
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    }
}

extension ViewController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location: CLLocation = locations.last!
    print("Location: \(location)")

    let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                          longitude: location.coordinate.longitude,
                                          zoom: zoomLevel)

    if mapView.isHidden {
      mapView.isHidden = false
      mapView.camera = camera
    } else {
      mapView.animate(to: camera)
    }

    self.locationManager?.stopUpdatingLocation()
    
  }

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
          print("Location access was restricted.")
        case .denied:
          print("User denied access to location.")
          // Display the map using the default location.
          mapView.isHidden = false
        case .notDetermined:
          print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
          print("Location status is OK.")
        @unknown default:
            print("unknow")
        }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    locationManager?.stopUpdatingLocation()
    print("Error: \(error)")
  }
}
