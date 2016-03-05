//
//  RouteUpload.swift
//  RunCapture
//
//  Created by Daniel Sauble on 3/4/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import Foundation

class RouteUpload: NSObject, NSURLSessionDelegate {
    
    static var singleton = RouteUpload()
    
    var task: NSURLSessionUploadTask?
    var session: NSURLSession?
    var id = "runcapture"
    
    override init() {
        self.session = nil;
        
        super.init()
        
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(id)
        self.session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    // Submit data to the web service
    func post(params: [Dictionary<String, String>], url: String) {
        
        // Configure HTTP request
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Serialize the JSON and write it to a file
        var path: String? = nil
        do {
            let options = NSJSONWritingOptions()
            let data = try NSJSONSerialization.dataWithJSONObject(params, options: options)
            
            // Create a file for upload
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docs: NSString = paths[0] as NSString
            path = docs.stringByAppendingPathComponent("uploadfile.json")
            let test = data.writeToFile(path!, atomically: true)
            if test {
                print("File written to disk successfully!")
            }
            else {
                print("File write FAILED")
            }
        }
        catch {
            print("Error serializing params!")
        }
            
        // Upload the JSON
        if let p = path {
            print("Uploading \(p) to \(url)")
            self.task = self.session?.uploadTaskWithRequest(request, fromFile: NSURL(fileURLWithPath: p));
            if let t = task {
                t.resume();
            }
        }
    }
    
    // NSURLSessionDelegate
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        print("Session invalidated!");
    }
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        print("Authentication requested");
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        print("All enqueued messages delivered");
    }
}