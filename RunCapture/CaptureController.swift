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
        Location.singleton.submitData(self.postURL)
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func abortRun(sender: AnyObject) {
        Location.singleton.stopCapture()
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
}

