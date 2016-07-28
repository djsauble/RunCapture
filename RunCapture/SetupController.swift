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
    
    @IBOutlet weak var logInView: UIView!
    
    @IBOutlet weak var tokenView: UIView!
    @IBOutlet weak var tokenFieldOne: UITextField!
    @IBOutlet weak var tokenFieldTwo: UITextField!
    @IBOutlet weak var tokenFieldThree: UITextField!
    @IBOutlet weak var tokenFieldFour: UITextField!
    
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
        URL.singleton.url = nil
        URL.singleton.saveURL()
        self.updateHideState()
    }
    
    func fetchGoal() {
        if let user = URL.singleton.user() {
            if let token = URL.singleton.token() {
                let ws = WebSocket()
                ws.event.open = {
                    ws.send("{\"type\": \"get_weekly_goal\", \"user\": \"\(user)\", \"token\": \"\(token)\"}")
                }
                ws.event.message = { message in
                    let data = String(message).dataUsingEncoding(NSUTF8StringEncoding)
                    do {
                        let object = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        Goal.singleton.distanceThisWeek = object["distanceThisWeek"] as? Double
                        Goal.singleton.goalThisWeek = object["goalThisWeek"] as? Double
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
            ws.send("{\"type\": \"use_token\", \"token\": \"\(token)\"}")
        }
        ws.event.message = { message in
            URL.singleton.url = NSURL(string: String(message))
            URL.singleton.saveURL()
            ws.close()
        }
        ws.event.close = { code, reason, clean in
            self.updateHideState()
        }
        ws.event.error = { err in
            URL.singleton.url = nil
            URL.singleton.saveURL()
            ws.close()
        }
        if (URL.ws.hasPrefix("wss")) {
            ws.allowSelfSignedSSL = true
        }
        ws.open(URL.ws)
    }
    
    func updateHideState() {
        // Show the token view if no URL is set
        if let url = URL.singleton.url {
            if url != "" {
                // Show the run button
                self.tokenView.hidden = true
                self.logInView.hidden = false
                return
            }
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

