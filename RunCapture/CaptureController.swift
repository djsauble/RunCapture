//
//  ViewController.swift
//  RunCapture
//
//  Created by Daniel Sauble on 2/28/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit
import MapKit

class CaptureController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var pointsOnRoute: [CLLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set up the location manager
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = kCLLocationAccuracyBestForNavigation
        
        // Initialize the points array
        self.pointsOnRoute = []
        
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
        pointsOnRoute.append(locations.last!)
        print(locations.last?.description)
    }
    
    @IBAction func endRun(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func abortRun(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
}

