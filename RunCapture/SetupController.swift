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

    @IBOutlet weak var urlTextField: UITextField!
    var url: URL = URL()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Make this controller handle any text field events
        urlTextField.delegate = self;
        
        // Restore the token URL, if previously set
        if let text = url.url {
            urlTextField.text = text
        }
        
        // Reset any capture data, get ready for the next run
        Location.singleton.resetCapture()
    }
    
    func websocketTest() {
        let ws = WebSocket()
        ws.event.open = {
            ws.send("{\"type\": \"use_token\", \"token\": \"\(self.urlTextField.text!)\"}")
        }
        ws.event.message = { message in
            self.urlTextField.text = String(message)
            ws.close()
        }
        // Production settings
        ws.allowSelfSignedSSL = true
        ws.open("wss://api-generator2.herokuapp.com/ws")
        
        // Test settings
        //ws.open("ws://127.0.0.1:5000/ws")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toCapture" {
            if let destinationVC = segue.destinationViewController as? CaptureController {
                if urlTextField.text?.characters.count > 0 {
                    // Reset the capture data
                    Location.singleton.resetCapture()
                    
                    // Set the URL based on the contents of the text box
                    url.url = urlTextField.text
                    destinationVC.postURL = url.url
                    url.saveURL()
                }
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // Attempt to retrieve the real URL from the server
        websocketTest()

        return true
    }
}

