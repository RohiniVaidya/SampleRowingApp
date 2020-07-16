//
//  MotionManager.swift
//  SampleRowingApp WatchKit Extension
//
//  Created by Rohini Vaidya on 7/10/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import Foundation
//import CreateML
import CoreMotion
import WatchKit
import os.log

import WatchConnectivity

class MotionManager {
    // MARK: Properties
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left
    
    // The app is using 50hz data and the buffer is going to hold 1s worth of data.
    let sampleInterval = 1.0 / 30
    
    
    var recentDetection = false
    var inputArray = [[String: Any]]()
    var fileTransfer: TransferData?
    //weak var delegate: MotionManagerDelegate?
    init() {
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }
    
    func startUpdates() {
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        os_log("Start Updates");
        
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            
            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!)
            }
        }
    }
    
    func stopUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
        if WatchSessionHandler.shared.isReachable(){
            
            WatchSessionHandler.shared.sendMessage(message: ["sensorvalues": self.inputArray])

        }
        else{
            NotificationCenter.default.post(name: .reachabilityDidChange, object: nil)
        }
    }
    
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatterGet.string(from: Date())
        
        let dictionary_data = [
            "date": dateString,
            "userAcceleration_x": deviceMotion.userAcceleration.x.round(to: 4),
            "userAcceleration_y": deviceMotion.userAcceleration.y.round(to: 4),
            "userAcceleration_z": deviceMotion.userAcceleration.z.round(to: 4),
            "rotation_x": deviceMotion.rotationRate.x.round(to: 4),
            "rotation_y": deviceMotion.rotationRate.y.round(to: 4),
            "rotation_z": deviceMotion.rotationRate.z.round(to: 4)
            ] as [String : Any]
        //        var bookTable = try MLDataTable(dictionary: dictionary_data)
        
        inputArray.append(dictionary_data)
        
        
    }
    
}


extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}


extension Double {
    func rounded(toDecimalPlaces n: Int) -> Double {
        return Double(String(format: "%.\(n)f", self))!
    }
    
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

}
