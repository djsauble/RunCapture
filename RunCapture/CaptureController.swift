//
//  ViewController.swift
//  RunCapture
//
//  Created by Daniel Sauble on 2/28/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CaptureController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    var locationManager: CLLocationManager!
    var pointsOnRoute: [CLLocation] = []
    var distance: Double = 0.0
    var postURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the location manager
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLLocationAccuracyBest
        
        // Clear counters
        pointsOnRoute = []
        distance = 0.0
        
        // Check authorization. Request location services.
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
            self.locationManager.startUpdatingLocation()
        }
        else {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    // Location services authorization changed, start updating the location
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedAlways {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    // Record the current location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Calculate meters traversed
        if let last = pointsOnRoute.last {
            self.distance += last.distanceFromLocation(locations.last!)
        }
        
        // Add the new point to the array
        pointsOnRoute.append(locations.last!)
        
        // Display distance
        distanceLabel.text = "\(round((distance / 1609.344) * 10.0) / 10.0) miles"
    }
    
    @IBAction func endRun(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func abortRun(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
}

