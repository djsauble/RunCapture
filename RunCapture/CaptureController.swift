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
    @IBOutlet weak var remainingLabel: UILabel!
    
    var currentDistance: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the callback for the location manager and start capturing data
        Location.singleton.callback = self.showProgress
        Location.singleton.startCapture()
        
        self.showProgress(0)
    }
    
    func showProgress(distance: Double) {
        
        self.currentDistance = floor((distance / 1609.344) * 10.0) / 10.0
        var remaining: Double? = nil
        
        // Goal for the week
        if let goal = Goal.singleton.goalThisWeek {
            remaining = goal
        }
        
        // Distance traversed this week
        if let d = Goal.singleton.distanceThisWeek {
            if let r = remaining {
                remaining = r - d
            }
        }
        
        // Distance traversed this run
        distanceLabel.text = "\(self.currentDistance) mi"
        
        // Remaining distance this week
        if let r = remaining {
            if r - self.currentDistance <= 0 {
                remainingLabel.text = "0 mi remaining"
                remainingLabel.textColor = UIColor.greenColor()
            }
            else {
                remainingLabel.text = "\(floor((r - self.currentDistance) * 10.0) / 10.0) mi remaining"
            }
        }
        else {
            remainingLabel.text = "— mi"
        }
    }
    
    @IBAction func endRun(sender: AnyObject) {
        Location.singleton.stopCapture()
        Location.singleton.submitData()
        
        // Save the data
        if let d = Goal.singleton.distanceThisWeek {
            Goal.singleton.distanceThisWeek = d + self.currentDistance
        }
        else {
            Goal.singleton.distanceThisWeek = self.currentDistance
        }
        Goal.singleton.save()
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func abortRun(sender: AnyObject) {
        Location.singleton.stopCapture()
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
}

