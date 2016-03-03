//
//  ViewController.swift
//  RunCapture
//
//  Created by Daniel Sauble on 2/28/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import UIKit

class SetupController: UIViewController {

    @IBOutlet weak var urlTextField: UITextField!
    var url: URL = URL()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Restore the token URL, if previously set
        if let text = url.url {
            urlTextField.text = text
        }
        
        // Reset any capture data, get ready for the next run
        Location.singleton.resetCapture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toCapture" {
            if let destinationVC = segue.destinationViewController as? CaptureController {
                if urlTextField.text?.characters.count > 0 {
                    url.url = urlTextField.text
                    destinationVC.postURL = url.url
                    url.saveURL()
                }
            }
        }
    }
}

