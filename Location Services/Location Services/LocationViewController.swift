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
    public var currentLocationLat = String()
    public var currentLocationLong = String()
    var locationManager: CLLocationManager!
    public var selectedCentre : Int = 0
    let centrePicker = UIPickerView()
    
    @IBOutlet weak var selectLocation: disableUITextField!
    
    @IBOutlet weak var googleMapView: GMSMapView!
    
    @IBOutlet weak var startDateField: disableUITextField!
    
    @IBOutlet weak var endDateField: disableUITextField!
    
    @IBAction func getLocationHistory(_ sender: Any) {
        fetchLocationHistory(url: apiURL)
    }
    
    @IBAction func shareLocation(_ sender: UIButton) {
        if(currentLocationLong == "" || currentLocationLat == ""){
            Toast.short(message: "Please Press Get Location to fetch Current Location", success: "1", failer: "0")
        } else{
            let googleMapLink = "http://www.google.com/maps/place/" + currentLocationLat + "," + currentLocationLong
            print(googleMapLink)
            let textShare = [ googleMapLink ]
            let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
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
        if(startDateField.text! == "" && endDateField.text! != ""){
            Toast.short(message: "Please pick a start Date", success: "1", failer: "0")
        } else if(startDateField.text! != "" && endDateField.text! == ""){
            Toast.short(message: "Please pick an end Date", success: "1", failer: "0")
        } else if(startDateField.text! == "" || endDateField.text! == ""){
            Toast.short(message: "Please pick both the Dates", success: "1", failer: "0")
        } else if(startDateField.text! != "" || endDateField.text! != ""){
            print(startDateField.text!)
            print(endDateField.text!)
            
            //Reference date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startDateObject = dateFormatter.date(from: startDateField.text!)!
            let endDateObject = dateFormatter.date(from: endDateField.text!)!
            let currentDateObject = Date()
            
            if(startDateObject > currentDateObject){
                Toast.short(message: "Start Date can't be in future!", success: "1", failer: "0")
            } else if(startDateObject > endDateObject){
                Toast.short(message: "Start Date can't be greater than End Date!", success: "1", failer: "0")
            } else {
                let dateRangeApiEndpoint = apiURL + "/date/" + startDateField.text! + "/" + endDateField.text!

                fetchLocationHistory(url: dateRangeApiEndpoint)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startAnimating(CGSize(width: 50, height: 30), message: "Loading...", type: NVActivityIndicatorType.ballSpinFadeLoader)
        googleMapView.delegate = self
        fetchLocationHistory(url: apiURL)
        createPickerView()
        dismissPickerView()
        // First Textfield
        let startDatePickerView = UIDatePicker()
        startDatePickerView.datePickerMode = .date
        startDateField.inputView = startDatePickerView
        startDatePickerView.addTarget(self, action: #selector(starthandleDatePicker), for: .valueChanged)
        
        // Second TextField
        let endDatePickerView = UIDatePicker()
        endDatePickerView.datePickerMode = .date
        endDateField.inputView = endDatePickerView
        endDatePickerView.addTarget(self, action: #selector(endhandleDatePicker), for: .valueChanged)
        
    }
    
    @objc func starthandleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        startDateField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func endhandleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        endDateField.text = dateFormatter.string(from: sender.date)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func locateMe(lat: Double, long: Double){
        self.googleMapView.clear()
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 17)
        self.googleMapView.camera = camera
        
        let initialLocation = CLLocationCoordinate2DMake(lat, long)
        let marker = GMSMarker(position: initialLocation)
        marker.map = nil
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
    
    func convertDateToHumanReadable(date: String) -> String {
        if(date == "" || date.isEmpty || date == "None"){
            return ""
        } else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your date format
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC") //Current time zone
            let date = dateFormatter.date(from: date) //according to date format your date string
            
            dateFormatter.dateFormat = "dd MMMM, yyyy HH:mm:ss" //New Date Format
            dateFormatter.timeZone = TimeZone.current
            let newDate = dateFormatter.string(from: date!) //pass Date here
            
            return newDate
        }
    }
    
    func detailsAndCameraPositioning(index: Int){
        self.googleMapView.clear()
        let camera = GMSCameraPosition.camera(withLatitude: latList[index], longitude: longList[index], zoom: 17)
        self.googleMapView.camera = camera
        
        let initialLocation = CLLocationCoordinate2DMake(latList[index], longList[index])
        let marker = GMSMarker(position: initialLocation)

        marker.title = "\(latList[index]), \(longList[index])"
        marker.map = googleMapView
        googleMapView.selectedMarker = marker
    }
    
    func getCurrentLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.distanceFilter = 200
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func fetchLocationHistory(url: String){
        self.latList = []
        self.longList = []
        self.timeList = []
        let request = AF.request(url)
        var index = 1
        request.responseJSON { (response) in
            let json = JSON(response.value!)

            for result in json.arrayValue{
                let long = result["longitude"].doubleValue
                let lat = result["latitude"].doubleValue
                let timeStamp = result["timestamp"].stringValue
                
                self.latList.append(lat)
                self.longList.append(long)
                self.timeList.append("\(index)" + ". " + self.convertDateToHumanReadable(date: timeStamp))
                index = index + 1
            }
        }
        Toast.long(message: "Check the Location Dropdown for updated Location History result", success: "1", failer: "0")
        stopAnimating()
    }
}

extension LocationViewController : CLLocationManagerDelegate {
    // MARK: Location Manager Delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        let locationsObj = locations.last! as CLLocation
        
        let locationLatitude = locationsObj.coordinate.latitude
        let locationLongitude = locationsObj.coordinate.longitude
        
        self.currentLocationLat = locationLatitude.string
        self.currentLocationLong = locationLongitude.string

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

extension LosslessStringConvertible {
    var string: String { .init(self) }
}
