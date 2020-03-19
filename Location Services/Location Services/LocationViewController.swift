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
import NVActivityIndicatorView
import Alamofire

class LocationViewController: UIViewController, GMSMapViewDelegate, NVActivityIndicatorViewable {
    
    public var latList = [Double]()
    public var longList = [Double]()
    public var timeList = [String]()
    
    @IBOutlet weak var latLongLabel: UILabel!
    
    @IBOutlet weak var googleMapView: GMSMapView!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        googleMapView.delegate = self
        fetchLocationHistory()
        
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

        startAnimating(CGSize(width: 50, height: 30), message: "Loading...", type: NVActivityIndicatorType.ballSpinFadeLoader)
        
    }
    
    func getCurrentLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func fetchLocationHistory(){
        let request = AF.request("https://location-history-server.herokuapp.com/location")
        
        request.responseJSON { (response) in
            let json = JSON(response.value!)
            print(json)
            for result in json.arrayValue{
                let long = result["longitude"].doubleValue
                let lat = result["latitude"].doubleValue
                let timeStamp = result["timestamp"].stringValue
                
                self.latList.append(lat)
                self.longList.append(long)
                self.timeList.append(timeStamp)
            }
        }
    }
    
}

extension LocationViewController : CLLocationManagerDelegate {
    // MARK: Location Manager Delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationsObj = locations.last! as CLLocation
        
        let locationLatitude = locationsObj.coordinate.latitude
        let locationLongitude = locationsObj.coordinate.longitude
        print("Current location lat-long is = \(locationLatitude) \(locationLongitude)")
        stopAnimating()
        
        self.detailsAndCameraPositioning(lat: locationLatitude, long: locationLongitude)
        self.latLongLabel.text = "Lat: \(locationLatitude), Long: \(locationLongitude)"
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Get Location failed")
    }

    func showOnMap(location: CLLocation) {
        //
    }
}
