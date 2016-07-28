//
//  URL.swift
//  RunCapture
//
//  Created by Daniel Sauble on 2/29/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import Foundation

class URL {
    
    static var singleton = URL()
    
    // Production
    static var ws = "wss://api-generator2.herokuapp.com/ws"
    
    // Local
    //static var ws = "ws://127.0.0.1:5000/ws"

    var url: NSURL? // The URL to post runs to
    
    init() {
        url = NSURL(string: (NSKeyedUnarchiver.unarchiveObjectWithFile(URL.ArchiveURL.path!) as? String)!)
    }
    
    func saveURL() {
        if let url = self.url {
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(url.absoluteString, toFile: URL.ArchiveURL.path!)
            
            if !isSuccessfulSave {
                print("Failed to save URL")
            }
        }
    }
    
    func user() -> String? {
        if let url = self.url {
            if let query = url.query {
                let components = query.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "=&"))
                return components[1]
            }
        }
        return nil
    }
    
    func token() -> String? {
        if let url = self.url {
            if let query = url.query {
                let components = query.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "=&"))
                return components[3]
            }
        }
        return nil
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("url")
}