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
    let sampleInterval = 1.0 / 20
    
    
    var recentDetection = false
    var inputArray = [[String: Any]]()
    var fileTransfer: TransferData?
    var timer: Timer? = nil
    private var rotXValues = [Double]()
    private var rotYValues = [Double]()
    private var rotZValues = [Double]()
    
//    @Published var sensorData: [[String: Any]] = []

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

                self.processDeviceMotion(deviceMotion!)
            }
        }
        DispatchQueue.main.async {
            if self.timer == nil{
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.detectPause), userInfo: nil, repeats: true)
            }
        }
        
    }
    
    func stopUpdates() {

//        print("DEBUG: input array \(self.inputArray)")
        self.timer?.invalidate()
        self.timer = nil
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
        
        NotificationCenter.default.post(name: .didUpdateSensorDate, object: self.inputArray)
        
    }
    
    func resetValues(){
        
        self.inputArray = []
        self.rotXValues = []
        self.rotYValues = []
        self.rotZValues = []
        last_array_count = 0
        rot_z_avgs = []
        rot_y_avgs = []
        rot_x_avgs = []
        activity = Activity.backward.rawValue
        log_id = 0
    }
    
    private var log_id: Int = 0
    private var activity = Activity.backward.rawValue
    
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let dateString = dateFormatterGet.string(from: Date())
        
        self.rotXValues.append(deviceMotion.rotationRate.x.round(to: 4))
        self.rotYValues.append(deviceMotion.rotationRate.y.round(to: 4))
        self.rotZValues.append(deviceMotion.rotationRate.z.round(to: 4))
        
        let dictionary_data = [
            "date": dateString,
            "userAcceleration_x": deviceMotion.userAcceleration.x.round(to: 4),
            "userAcceleration_y": deviceMotion.userAcceleration.y.round(to: 4),
            "userAcceleration_z": deviceMotion.userAcceleration.z.round(to: 4),
            "rotation_x": deviceMotion.rotationRate.x.round(to: 4),
            "rotation_y": deviceMotion.rotationRate.y.round(to: 4),
            "rotation_z": deviceMotion.rotationRate.z.round(to: 4),
            "roll": deviceMotion.attitude.roll.round(to: 4),
            "pitch": deviceMotion.attitude.pitch.round(to: 4),
            "yaw": deviceMotion.attitude.yaw.round(to: 4),
            "gravity_x": deviceMotion.gravity.x.round(to: 4),
            "gravity_y": deviceMotion.gravity.y.round(to: 4),
            "gravity_z": deviceMotion.gravity.z.round(to: 4),
            "activity": activity,
            "id": log_id
            ] as [String : Any]
        inputArray.append(dictionary_data)
        
    }

    
    var array_of_avgs = [Double]()
    private var count: Int = 0
    private var last_array_count: Int = 0
    private var isForward = true

    var rot_x_avgs = [Double]()
    var rot_y_avgs = [Double]()
    var rot_z_avgs = [Double]()
    var newArray = [Double]()

    var sensorValues = [[String:Any]]()

    @objc func detectPause(){
        
    


        let currentArrayLength = rotXValues.count
        newArray.removeAll()

        if last_array_count < currentArrayLength{
            print("DEBUG: currentArrayLength \(currentArrayLength)")

            print("DEBUG: last array count \(last_array_count)")
            let newLength = currentArrayLength - last_array_count
            for i in 0..<newLength{
                newArray.append(abs(rotXValues[last_array_count + i]))
            }

            let currentBatch = rotXValues[last_array_count..<currentArrayLength]
            print("DEBUG: currentBatch\(currentBatch)")

            last_array_count += currentBatch.count

            getPause(newValues: newArray)
        }
        
//        let currentArrayLength = self.inputArray.count
//        sensorValues.removeAll()
//
//        if last_array_count < currentArrayLength{
//            print("DEBUG: currentArrayLength \(currentArrayLength)")
//
//            print("DEBUG: last array count \(last_array_count)")
//            let newLength = currentArrayLength - last_array_count
//            for i in 0..<newLength{
//                sensorValues.append(self.inputArray[last_array_count + i])
//            }
//
//            let currentBatch = inputArray[last_array_count..<currentArrayLength]
////            print("DEBUG: currentBatch\(currentBatch)")
//
//            last_array_count += currentBatch.count
//
//            for i in 0..<(sensorValues.count - 1){
//                vectorMath(vectorA: sensorValues[i], vectorB: sensorValues[i+1])
//            }
//
//        }

        
        
    }
    
    
    func vectorMath(vectorA: [String: Any], vectorB: [String: Any]){
        
        var cos_angle = 0.0
        guard let vectorA_X = vectorA["userAcceleration_x"] as? Double else { return }
        guard let vectorB_X = vectorB["userAcceleration_x"] as? Double else { return }
        guard let vectorA_Y = vectorA["userAcceleration_y"] as? Double else { return }
        guard let vectorB_Y = vectorB["userAcceleration_y"] as? Double else { return }
        guard let vectorA_Z = vectorA["userAcceleration_z"] as? Double else { return }
        guard let vectorB_Z = vectorB["userAcceleration_z"] as? Double else { return }

        let sumOfProducts = (vectorA_X * vectorB_X) + (vectorA_Y * vectorB_Y) + (vectorA_Z * vectorB_Z)
        let sumOfSquareOfA = pow(vectorA_X, 2) + pow(vectorA_Y, 2) + pow(vectorA_Z, 2)
        let rootOfVectorA = sqrt(sumOfSquareOfA)
        
        let sumOfSquareOfB = pow(vectorB_X, 2) + pow(vectorB_Y, 2) + pow(vectorB_Z, 2)
        let rootOfVectorB = sqrt(sumOfSquareOfB)
        
        cos_angle = sumOfProducts / (rootOfVectorA * rootOfVectorB)
        
        print("DEBUG: cos_angle \(cos_angle)")
    }
    
    

    var pauseIndices = [Int]()
    
    func getPause(newValues: [Double])
    {
        let length = newArray.count - 1
        let mainArrayLength = self.inputArray.count - 1
        for i in 0..<10{
            
            let sensorValue = newArray[length - i]
            if sensorValue < 0.1 {
                count += 1
                print("DEBUG: sesnor val \(sensorValue)")
                pauseIndices.append(i)
            }
            
        }
        
        if count >= 4{
            WKInterfaceDevice.current().play(.success)
            
            count = 0
            for i in 0..<pauseIndices.count{
                self.inputArray[mainArrayLength-i]["id"] = -1
                self.inputArray[mainArrayLength-i]["activity"] = Activity.pause.rawValue
            }
            self.storeStrokeData(for: self.isForward)
            isForward.toggle()
            pauseIndices.removeAll()
            
        }
        count = 0
    }
    
    
    
    func identifyPause(newArray: [Double]){
        let length = newArray.count - 1
        let mainArrayLength = self.inputArray.count - 1
//        guard let max = newArray.max() else {return }
        for i in 0..<10{
            let sensorValue = newArray[length - i]
            if sensorValue < 0.1 {
                count += 1
                print("DEBUG: sesnor val \(sensorValue)")
                pauseIndices.append(i)
            }
//            let differnce = percentageDifference(min: sensorValue, max: max)
//            if differnce > 0.9{
//                print("DEBUG: max: \(max) recent: \(sensorValue)")
//                pauseValues.append(differnce)
//            }
            
        }
        
        if count >= 4{
            WKInterfaceDevice.current().play(.success)

            count = 0
            for i in 0..<pauseIndices.count{
                self.inputArray[mainArrayLength-i]["id"] = -1
                self.inputArray[mainArrayLength-i]["activity"] = Activity.pause.rawValue
            }
            self.storeStrokeData(for: self.isForward)
            isForward.toggle()
            pauseIndices.removeAll()

        }
        count = 0

//        if pauseValues.count >= 4{
//            for i in 0..<4{
//                self.inputArray[mainArrayLength-i]["id"] = -1
//                self.inputArray[mainArrayLength-i]["activity"] = Activity.pause.rawValue
//            }
//            self.storeStrokeData(for: self.isForward)
//            isForward.toggle()
//            pauseValues.removeAll()
//        }else{
//            pauseValues.removeAll()
//        }
        
    }
    
    
    func performBasicComputation(incomingArray: [Double]) -> Double{
        let currentArrayLength = incomingArray.count
        if last_array_count < currentArrayLength{
            let currentBatch = incomingArray[last_array_count..<currentArrayLength]
            last_array_count = currentBatch.count
            
            let batchSum = currentBatch.sum()
            
            let batchAvg = batchSum / Double(currentBatch.count)
            return batchAvg
        }
        return 0.0
    }
    
    func performMaxComputation(){
        
        guard let maxX = rotXValues.max() else { return }
        guard let maxY = rotYValues.max() else { return }
        guard let maxZ = rotZValues.max() else { return }

        guard let minX = rot_x_avgs.last else { return }
        guard let minY = rot_y_avgs.last else { return }
        guard let minZ = rot_z_avgs.last else { return }
        
        let diffX = percentageDifference(min: minX, max: maxX)
        let diffY = percentageDifference(min: minY, max: maxY)
        let diffZ = percentageDifference(min: minZ, max: maxZ)
        
        //check of 2 of 3 satify condition consistently
        let values = [diffX, diffY, diffZ].filter {
            $0 > 0.9
        }
        
        if values.count >= 2{
            count += 1
            if count == 2{
                count = 0
                
                print("DEBUG: max \(maxX), \(maxY), \(maxZ) min \(minX), \(minY) ,\(minZ) percDiff \(diffX), \(diffY), \(diffZ)")

                self.storeStrokeData(for: self.isForward)
                isForward.toggle()
            }
        }
        else{
            count = 0
        }
        
    }
    
    
    func storeStrokeData(for forwardStroke: Bool){
        self.log_id += 1
        if forwardStroke{
            self.activity = Activity.forward.rawValue
        }
        else{
            self.activity = Activity.backward.rawValue
        }
    }
    
    func percentageDifference(min: Double, max: Double) -> Double{
        let diff = max-min
        return diff/max
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
