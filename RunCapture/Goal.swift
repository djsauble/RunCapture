//
//  Goal.swift
//  RunCapture
//
//  Created by Daniel Sauble on 7/27/16.
//  Copyright © 2016 Daniel Sauble. All rights reserved.
//

import Foundation

class Goal {
    
    static var singleton = Goal()
    
    var distanceThisWeek: Double? // How far have we run this week?
    var goalThisWeek: Double? // How far are we aspiring to run this week?
    
    init() {
        //distanceThisWeek = NSKeyedUnarchiver.unarchiveObjectWithFile(Goal.DistanceArchiveURL.path!) as? Double
        //goalThisWeek = NSKeyedUnarchiver.unarchiveObjectWithFile(Goal.GoalArchiveURL.path!) as? Double
    }
    
    /*func save() {
        if let distance = self.distanceThisWeek {
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(distance, toFile: Goal.DistanceArchiveURL.path!)
            
            if !isSuccessfulSave {
                print("Failed to save distance this week")
            }
        }
        
        if let goal = self.goalThisWeek {
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(goal, toFile: Goal.GoalArchiveURL.path!)
            
            if !isSuccessfulSave {
                print("Failed to save goal this week")
            }
        }
    }*/
    
    // MARK: Archiving Paths
    
    /*static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let DistanceArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("distanceThisWeek")
    static let GoalArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("goalThisWeek")*/
}