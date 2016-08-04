//
//  ViewController.swift
//  RunCapture
//
//  Created by Daniel Sauble on 2/28/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit
import SwiftWebSocket

class SetupController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var tokenView: UIView!
    @IBOutlet weak var tokenFieldOne: UITextField!
    @IBOutlet weak var tokenFieldTwo: UITextField!
    @IBOutlet weak var tokenFieldThree: UITextField!
    @IBOutlet weak var tokenFieldFour: UITextField!
    
    @IBOutlet weak var logInView: UIView!
    @IBOutlet weak var weeklyGoalValue: UILabel!
    @IBOutlet weak var weeklyProgressValue: UILabel!
    @IBOutlet weak var weeklyRemainingValue: UILabel!
    @IBOutlet weak var weeklyRemainingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do we have a URL?
        updateHideState()
        
        // Listen for notifications
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let mainQueue = NSOperationQueue.mainQueue()
        let _ = notificationCenter.addObserverForName(UITextFieldTextDidChangeNotification, object: nil, queue: mainQueue) { notification in
            if let textField = notification.object as! UITextField! {
                if textField == self.tokenFieldOne {
                    self.tokenFieldTwo.becomeFirstResponder()
                }
                else if textField == self.tokenFieldTwo {
                    self.tokenFieldThree.becomeFirstResponder()
                }
                else if textField == self.tokenFieldThree {
                    self.tokenFieldFour.becomeFirstResponder()
                }
                else if textField == self.tokenFieldFour {
                    textField.resignFirstResponder()
                    
                    // Attempt to retrieve the real URL from the server
                    self.fetchURL()
                }
            }
        }
        
        // Make this controller handle any text field events
        tokenFieldOne.delegate = self
        tokenFieldTwo.delegate = self
        tokenFieldThree.delegate = self
        tokenFieldFour.delegate = self
        
        // Reset any capture data, get ready for the next run
        Location.singleton.resetCapture()
        
        // Fetch goals on page load
        self.fetchGoal()
        
        // Display goal data
        self.updateGoals()
    }
    
    override func viewDidAppear(animated: Bool) {
        if animated {
            self.updateGoals()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toCapture" {
            // Reset the capture data
            Location.singleton.resetCapture()
            
            // Fetch goal data from the server
            self.fetchGoal()
        }
    }
    
    @IBAction func logOut(sender: AnyObject) {
        URL.singleton.reset()
        self.updateHideState()
    }
    
    func fetchGoal() {
        if let user = URL.singleton.user {
            if let token = URL.singleton.token {
                let ws = WebSocket()
                ws.event.open = {
                    ws.send("{\"type\": \"weekly_goal:get\", \"data\": {\"user\": \"\(user)\", \"token\": \"\(token)\"} }")
                }
                ws.event.message = { message in
                    let data = String(message).dataUsingEncoding(NSUTF8StringEncoding)
                    do {
                        let object = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        Goal.singleton.distanceThisWeek = object["data"]!!["distanceThisWeek"] as? Double
                        Goal.singleton.goalThisWeek = object["data"]!!["goalThisWeek"] as? Double
                        Goal.singleton.save()
                        
                        // Display goal data
                        self.updateGoals()
                    }
                    catch {
                        // Recover
                    }
                    ws.close()
                }
                ws.event.close = { code, reason, clean in
                }
                ws.event.error = { err in
                    print("Error fetching goal data from server")
                    ws.close()
                }
                if (URL.ws.hasPrefix("wss")) {
                    ws.allowSelfSignedSSL = true
                }
                ws.open(URL.ws)
            }
        }
    }
    
    func fetchURL() {
        let token = "\(self.tokenFieldOne.text!)\(self.tokenFieldTwo.text!)\(self.tokenFieldThree.text!)\(self.tokenFieldFour.text!)"
        let ws = WebSocket()
        ws.event.open = {
            ws.send("{\"type\": \"passcode:use\", \"data\": {\"passcode\": \"\(token)\"} }")
        }
        ws.event.message = { message in
            let data = String(message).dataUsingEncoding(NSUTF8StringEncoding)
            do {
                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                URL.singleton.user = object["data"]!!["user"] as? String
                URL.singleton.token = object["data"]!!["token"] as? String
                URL.singleton.save()
            }
            catch {
                // Recover
            }
            ws.close()
            
            // Fetch goal data from the server
            self.fetchGoal()
        }
        ws.event.close = { code, reason, clean in
            self.updateHideState()
        }
        ws.event.error = { err in
            URL.singleton.reset()
            ws.close()
        }
        if (URL.ws.hasPrefix("wss")) {
            ws.allowSelfSignedSSL = true
        }
        ws.open(URL.ws)
    }
    
    func updateGoals() {
        var remaining: Double? = nil
        
        // Goal for the week
        if let goal = Goal.singleton.goalThisWeek {
            weeklyGoalValue.text = "\(floor(goal * 10.0) / 10.0) mi"
            remaining = goal
        }
        else {
            weeklyGoalValue.text = "— mi"
        }
        
        // Distance traversed this week
        if let d = Goal.singleton.distanceThisWeek {
            weeklyProgressValue.text = "- \(floor(d * 10.0) / 10.0) mi"
            if let r = remaining {
                remaining = r - d
            }
        }
        else {
            weeklyProgressValue.text = "— mi"
        }
        
        // Remaining distance this week
        if let r = remaining {
            if r <= 0 {
                weeklyRemainingValue.text = "0 mi"
                weeklyRemainingValue.textColor = UIColor.greenColor()
                weeklyRemainingLabel.textColor = UIColor.greenColor()
            }
            else {
                weeklyRemainingValue.text = "\(floor(r * 10.0) / 10.0) mi"
            }
        }
        else {
            weeklyRemainingValue.text = "— mi"
        }
    }
    
    func updateHideState() {
        // Show the token view if no URL is set
        if URL.singleton.url() !== nil {
            // Show the run button
            self.tokenView.hidden = true
            self.logInView.hidden = false
            return
        }
        
        // Otherwise, request a token (clear the text fields and put focus in the first one)
        self.tokenFieldOne.text = ""
        self.tokenFieldTwo.text = ""
        self.tokenFieldThree.text = ""
        self.tokenFieldFour.text = ""
        self.tokenView.hidden = false
        self.logInView.hidden = true
        self.tokenFieldOne.becomeFirstResponder()
    }
}

