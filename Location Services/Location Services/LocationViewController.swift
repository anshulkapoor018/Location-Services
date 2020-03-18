//
//  LocationViewController.swift
//  Location Services
//
//  Created by Anshul Kapoor on 17/03/20.
//  Copyright © 2020 Anshul Kapoor. All rights reserved.
//
// Google Maps API key AIzaSyB83bApNZP4dvpmpRW8nCowKogLI-DVWg0
import UIKit
import GoogleMaps
import SwiftyJSON

class LocationViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var googleMapView: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        googleMapView.delegate = self
    }
}
