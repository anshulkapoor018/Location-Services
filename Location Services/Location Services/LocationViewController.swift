//
//  LocationViewController.swift
//  Location Services
//
//  Created by Anshul Kapoor on 17/03/20.
//  Copyright © 2020 Anshul Kapoor. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import CoreLocation
import MapKit

class LocationViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var latLongLabel: UILabel!
    
    @IBOutlet weak var googleMapView: GMSMapView!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        googleMapView.delegate = self
    }
    
    func detailsAndCameraPositioning(lat: Double, long: Double){
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17)
        self.googleMapView.camera = camera
        
        let initialLocation = CLLocationCoordinate2DMake(lat, long)
        let marker = GMSMarker(position: initialLocation)
        marker.title = "YO"
        
        marker.map = googleMapView
        googleMapView.selectedMarker = marker
    }
    
    @IBAction func getLocation(_ sender: UIButton) {
        self.getCurrentLocation()
    }
    
    func getCurrentLocation()
    {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
}

extension LocationViewController : CLLocationManagerDelegate {
    // MARK: Location Manager Delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationsObj = locations.last! as CLLocation
        
//        print("Current location lat-long is = \(locationsObj.coordinate.latitude) \(locationsObj.coordinate.longitude)")
        
        self.detailsAndCameraPositioning(lat: locationsObj.coordinate.latitude, long: locationsObj.coordinate.longitude)
        self.latLongLabel.text = "Lat: \(locationsObj.coordinate.latitude), Long: \(locationsObj.coordinate.longitude)"
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Get Location failed")
    }

    func showOnMap(location: CLLocation) {
        //
    }
}
