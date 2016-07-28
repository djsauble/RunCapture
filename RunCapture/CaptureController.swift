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
    
    @IBOutlet weak var weekGoalLabel: UILabel!
    @IBOutlet weak var weekDistanceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var remainingTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the callback for the location manager and start capturing data
        Location.singleton.callback = self.showProgress
        Location.singleton.startCapture()
    }
    
    func showProgress(distance: Double) {
        
        let miles = floor((distance / 1609.344) * 10.0) / 10.0
        var remaining: Double? = nil
        
        // Goal for the week
        if let goal = Goal.singleton.goalThisWeek {
            weekGoalLabel.text = "\(goal) mi"
            remaining = goal
        }
        else {
            weekGoalLabel.text = "— mi"
        }
        
        // Distance traversed this week
        if let d = Goal.singleton.distanceThisWeek {
            weekDistanceLabel.text = "\(d) mi"
            if let r = remaining {
                remaining = r - d
            }
        }
        else {
            weekDistanceLabel.text = "— mi"
        }
        
        // Distance traversed this run
        distanceLabel.text = "\(miles) mi"
        
        // Remaining distance this week
        if let r = remaining {
            if r <= 0 {
                remainingLabel.text = "0 mi"
                remainingLabel.textColor = UIColor.greenColor()
                remainingTextLabel.textColor = UIColor.greenColor()
            }
            else {
                remainingLabel.text = "\(r - miles) mi"
            }
        }
        else {
            remainingLabel.text = "— mi"
        }
    }
    
    @IBAction func endRun(sender: AnyObject) {
        Location.singleton.stopCapture()
        Location.singleton.submitData()
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func abortRun(sender: AnyObject) {
        Location.singleton.stopCapture()
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
}

