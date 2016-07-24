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
    
    var url: String? // The URL to post runs to
    
    init() {
        url = NSKeyedUnarchiver.unarchiveObjectWithFile(URL.ArchiveURL.path!) as? String
    }
    
    func saveURL() {
        if let url = self.url {
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(url, toFile: URL.ArchiveURL.path!)
            
            if !isSuccessfulSave {
                print("Failed to save URL")
            }
        }
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("url")
}