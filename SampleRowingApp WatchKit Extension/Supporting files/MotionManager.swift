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



class MotionManager: NSObject {
    // MARK: Properties
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left
    
    // The app is using 50hz data and the buffer is going to hold 1s worth of data.
    let sampleInterval = 1.0 / 50
    
    let rateAlongGravityBuffer = RunningBuffer(size: 50)
    
    var recentDetection = false
    var inputArray = [[String: Any]]()
    var fileTransfer: TransferData?
    
    
    private var log_id: Int = 0
    private var activity = Activity.backward.rawValue
    
    private var isForward = false
    


    //weak var delegate: MotionManagerDelegate?
    override init() {
        super.init()
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }
    
    func startUpdates() {
        resetValues()
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
//                self.getValue(deviceMotion: deviceMotion!)
                self.processThrust(deviceMotion!)
            }
        }

        
    }
    
    func stopUpdates() {

        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
        
        NotificationCenter.default.post(name: .didUpdateSensorDate, object: self.inputArray)
        
    }
    
   
    
    func processThrust(_ deviceMotion: CMDeviceMotion) {
        let userAcceleration = deviceMotion.userAcceleration
        let userAccelerationMagnitude = sqrt(pow(userAcceleration.x, 2) + pow(userAcceleration.y, 2) + pow(userAcceleration.z, 2))
               
        let rotationRate = deviceMotion.rotationRate

        let rotationRateMag = sqrt(pow(rotationRate.x, 2) + pow(rotationRate.y, 2) + pow(rotationRate.z, 2))
        if userAccelerationMagnitude < 0.1 && rotationRateMag < 1.0{
            rateAlongGravityBuffer.addSample(userAccelerationMagnitude)
            if rateAlongGravityBuffer.count() > 5{
                WKInterfaceDevice.current().play(.success)

                addActivityLabel(deviceMotion: deviceMotion, isDirectionChanged: false, id: -1)
            }
        }
        else{
            if rateAlongGravityBuffer.count() > 5{
                addActivityLabel(deviceMotion: deviceMotion, isDirectionChanged: true, id: 0)

            }
            else{
                self.addActivityLabel(deviceMotion: deviceMotion, isDirectionChanged: false, id: 0)
            }

            rateAlongGravityBuffer.reset()
        }
    }
    
    func addActivityLabel(deviceMotion: CMDeviceMotion, isDirectionChanged: Bool, id: Int){
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let dateString = dateFormatterGet.string(from: Date())
        
        let userAcceleration = deviceMotion.userAcceleration
        let rotationRate = deviceMotion.rotationRate
        let attitude = deviceMotion.attitude
        let gravity = deviceMotion.gravity
        
        var dictionary_data = [
                             "date": dateString,
                             "userAcceleration_x": userAcceleration.x.round(to: 4),
                             "userAcceleration_y": userAcceleration.y.round(to: 4),
                             "userAcceleration_z": userAcceleration.z.round(to: 4),
                             "rotation_x": rotationRate.x.round(to: 4),
                             "rotation_y": rotationRate.y.round(to: 4),
                             "rotation_z": rotationRate.z.round(to: 4),
                             "roll": attitude.roll.round(to: 4),
                             "pitch": attitude.pitch.round(to: 4),
                             "yaw": attitude.yaw.round(to: 4),
                             "gravity_x": gravity.x.round(to: 4),
                             "gravity_y": gravity.y.round(to: 4),
                             "gravity_z": gravity.z.round(to: 4)
        ] as [String : Any]
        
        if isDirectionChanged{
            isForward.toggle()
            log_id += 1
            
            dictionary_data["activity"] = isForward ? Activity.forward.rawValue : Activity.backward.rawValue
            dictionary_data["id"] = log_id
            
            inputArray.append(dictionary_data)
            
        }
        else{
            if id == -1{
                dictionary_data["activity"] = Activity.pause.rawValue
                dictionary_data["id"] = -1
               
                inputArray.append(dictionary_data)
            }
            else{
                dictionary_data["activity"] = isForward ? Activity.forward.rawValue : Activity.backward.rawValue
                dictionary_data["id"] = log_id
                
                inputArray.append(dictionary_data)
            }
            
        }
        

    }
    
    func resetValues(){
        
        rateAlongGravityBuffer.reset()

        self.inputArray = []

        activity = Activity.backward.rawValue
        log_id = 0
    }
    
}

extension Sequence where Element: AdditiveArithmetic {
    /// Returns the total sum of all elements in the sequence
    func sum() -> Element { reduce(.zero, +) }
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


enum Activity: String{
    case forward = "forward"
    case backward = "backward"
    case pause = "pause"
}
