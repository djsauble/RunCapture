//
//  Location.swift
//  RunCapture
//
//  Created by Daniel Sauble on 3/2/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {
    
    static var singleton = Location()
    
    var locationManager: CLLocationManager
    var pointsOnRoute: [CLLocation] = []
    var distance: Double = 0.0
    var capturingData: Bool = false
    var deferringUpdates: Bool = false
    var callback: ((distance: Double) -> Void)?
    
    override init() {
        
        // Set instance variables
        self.locationManager = CLLocationManager()
        
        super.init()
        
        // Set up the location manager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        // Check authorization. Request location services.
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
            self.locationManager.startUpdatingLocation()
        }
        else {
            self.locationManager.requestAlwaysAuthorization()
        }
    }

    // Reset counters
    func resetCapture() {
        self.pointsOnRoute = []
        self.distance = 0.0
    }
    
    // Start/resume capturing data
    func startCapture() {
        
        // Set capture flag to true
        self.capturingData = true;
    }
    
    // Stop capturing data
    func stopCapture() {
        self.capturingData = false;
    }
    
    // Location services authorization changed, start updating the location
    @objc func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedAlways {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    // Record the current location
    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !self.capturingData {
            return
        }
        
        // Calculate additional distance traveled
        if locations.count > 0 {
            
            // Calculate meters traversed
            if let last = pointsOnRoute.last {
                distance += last.distanceFromLocation(locations.first!)
            }
        }
        if locations.count > 1 {
            for i in 1..<locations.count {
                distance += locations[i].distanceFromLocation(locations[i - 1])
            }
        }
            
        // Add the new points to the array
        pointsOnRoute.appendContentsOf(locations)
            
        // Pass distance to the callback
        if let cb = self.callback {
            cb(distance: distance);
        }
        
        // Defer updates when the app is backgrounded
        if !self.deferringUpdates {
            self.locationManager.allowDeferredLocationUpdatesUntilTraveled(CLLocationDistanceMax, timeout: CLTimeIntervalMax)
            self.deferringUpdates = true
        }
    }
    
    // Prepare data for submission
    func submitData(postURL: String?) {
        if let url = postURL {
            let params = Location.singleton.pointsOnRoute.map({
                (location: CLLocation) -> Dictionary<String, String> in
                return [
                    "latitude": String(location.coordinate.latitude),
                    "longitude": String(location.coordinate.longitude),
                    "accuracy": String(location.horizontalAccuracy),
                    "timestamp": location.timestamp.descriptionWithLocale(nil),
                    "speed": String(location.speed)
                ]
            })
            
            RouteUpload.singleton.post(params, url: url)
        }
    }
}