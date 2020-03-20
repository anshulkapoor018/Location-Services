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
    
    public var apiURL = "https://location-history-server.herokuapp.com/location"
    public var latList = [Double]()
    public var longList = [Double]()
    public var timeList = [String]()
    var locationManager: CLLocationManager!
    public var selectedCentre : Int = 0
    let centrePicker = UIPickerView()
    
    @IBOutlet weak var selectLocation: disableUITextField!
    
    @IBOutlet weak var googleMapView: GMSMapView!
    
    @IBOutlet weak var startDateField: UITextField!
    
    @IBOutlet weak var endDateField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        googleMapView.delegate = self
        fetchLocationHistory(url: apiURL)
        createPickerView()
        dismissPickerView()
    }
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        selectLocation.inputView = pickerView
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        selectLocation.inputAccessoryView = toolBar
    }
    
    @objc func action() {
       view.endEditing(true)
    }
    
    func locateMe(lat: Double, long: Double){
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17)
        self.googleMapView.camera = camera
        
        let initialLocation = CLLocationCoordinate2DMake(lat, long)
        let marker = GMSMarker(position: initialLocation)
        
        marker.map = googleMapView
        marker.title = "\(lat), \(long)"
        googleMapView.selectedMarker = marker
        let parameters: [String: Double] = [
            "latitude" : lat,
            "longitude" : long
        ]
        
        print(parameters)
        
        //Posting the new geolocation via post request
        AF.request("https://location-history-server.herokuapp.com/location", method: .post, parameters: parameters, encoding: JSONEncoding.default)
        .responseJSON { response in
            print(response)
        }
    }
    
    func detailsAndCameraPositioning(index: Int){
        
        let camera = GMSCameraPosition.camera(withLatitude: latList[index], longitude: longList[index], zoom: 17)
        self.googleMapView.camera = camera
        
        let initialLocation = CLLocationCoordinate2DMake(latList[index], longList[index])
        let marker = GMSMarker(position: initialLocation)

        marker.title = "\(latList[index]), \(longList[index])"
        marker.map = googleMapView
        googleMapView.selectedMarker = marker
    }
    
    @IBAction func getLocationHistory(_ sender: Any) {
        fetchLocationHistory(url: apiURL)
    }
    
    @IBAction func getLocation(_ sender: UIButton) {
        self.getCurrentLocation()

        startAnimating(CGSize(width: 50, height: 30), message: "Loading...", type: NVActivityIndicatorType.ballSpinFadeLoader)
        
    }
    
    @IBAction func getLast5(_ sender: UIButton) {
        let lastFiveLocationURL = apiURL + "/limit/5"
        fetchLocationHistory(url: lastFiveLocationURL)
    }
    
    @IBAction func getDateRangeLocations(_ sender: UIButton) {
    
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
    
    func fetchLocationHistory(url: String){
        self.latList = []
        self.longList = []
        self.timeList = []
        let request = AF.request(url)
        
        request.responseJSON { (response) in
            let json = JSON(response.value!)

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
//        print("Current location lat-long is = \(locationLatitude) \(locationLongitude)")
        stopAnimating()
        
        self.locateMe(lat: locationLatitude, long: locationLongitude)

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Get Location failed")
    }

    func showOnMap(location: CLLocation) {
        //
    }
}

extension LocationViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeList[row]
       
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCentre = row
        selectLocation.text = timeList[row]
        self.detailsAndCameraPositioning(index: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
        label.font = UIFont (name: "Helvetica Neue", size: 12)
        label.text =  timeList[row]
        label.textAlignment = .center
        return label
    }
}

extension LocationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return false
    }
}
