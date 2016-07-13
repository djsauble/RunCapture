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
    var accuracyThreshold: Double = 20.0
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
        
        // Add the new points to the array
        self.pointsOnRoute.appendContentsOf(locations)
        
        // Calculate distance traveled
        self.refreshDistance()
            
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
    
    // Calculate additional distance traveled
    func refreshDistance() {
        print("---")
        print(">> start")
        var accuratePoints: [CLLocation] = [];
        var contiguousPoints: [CLLocation] = [];
        
        // Filter out inaccurate points
        accuratePoints = self.pointsOnRoute.filter({
            (location: CLLocation) -> Bool in
            return location.horizontalAccuracy <= self.accuracyThreshold
        })
        
        if accuratePoints.count <= 1 {
            return;
        }
        
        // Filter out discontinuities (points that aren't adjacent to any other points), excluding the first and last points
        if accuratePoints.count >= 3 {
            for i in 1..<(accuratePoints.count - 1) {
                let d1 = accuratePoints[i-1].distanceFromLocation(accuratePoints[i]);
                let d2 = accuratePoints[i].distanceFromLocation(accuratePoints[i+1]);
                if d1 <= self.accuracyThreshold && d2 <= self.accuracyThreshold {
                    contiguousPoints.append(accuratePoints[i]);
                }
            }
        }
        
        if accuratePoints.count >= 2 {
            // See if the first point is a discontinuity
            let firstPoint = accuratePoints.first!
            let nextPoint = accuratePoints[1]
            if firstPoint.distanceFromLocation(nextPoint) <= self.accuracyThreshold {
                contiguousPoints.insert(firstPoint, atIndex: 0);
            }
        
            // See if the last point is a discontinuity
            let penultimatePoint = accuratePoints[accuratePoints.count - 2]
            let lastPoint = accuratePoints.last!
            if penultimatePoint.distanceFromLocation(lastPoint) <= self.accuracyThreshold {
                contiguousPoints.append(lastPoint);
            }
        }
        
        // Must be at least two points to calculate distance
        if contiguousPoints.count <= 1 {
            return;
        }
        
        // Calculate meters traversed
        var d: Double = 0.0;
        for i in 1..<contiguousPoints.count {
            d += contiguousPoints[i - 1].distanceFromLocation(contiguousPoints[i])
        }
        distance = d;
        print(contiguousPoints.count)
        print(distance)
        print("<< end")
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