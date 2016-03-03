//
//  ViewController.swift
//  RunCapture
//
//  Created by Daniel Sauble on 2/28/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit
import CoreLocation

class CaptureController: UIViewController {
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    var postURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the callback for the location manager and start capturing data
        Location.singleton.callback = self.showProgress
        Location.singleton.startCapture()
    }
    
    func showProgress(distance: Double) {
        distanceLabel.text = "\(floor((distance / 1609.344) * 10.0) / 10.0) miles"
    }
    
    @IBAction func endRun(sender: AnyObject) {
        Location.singleton.stopCapture()
        
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
            
            post(params, url: url)
        }
        
        Location.singleton.resetCapture()
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func abortRun(sender: AnyObject) {
        Location.singleton.stopCapture()
        Location.singleton.resetCapture()
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func post(params: [Dictionary<String, String>], url: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        do {
            let options = NSJSONWritingOptions()
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: options)
        }
        catch {
            print("Error serializing params!")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            var json: NSDictionary?
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
            }
            catch {
                print("Error parsing JSON!")
            }
            
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                let success = parseJSON["success"] as? Int
                print("Success: \(success)")
            }
            else {
                // Whoa, okay the json object was nil, something went wrong. Maybe the server isn't running?
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Error could not parse JSON: \(jsonStr)")
            }
        })
        
        task.resume()
    }
}

