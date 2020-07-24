//
//  Interactor.swift
//  SampleRowingApp WatchKit Extension
//
//  Created by Rohini Vaidya on 7/23/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import Foundation

class Interactor: NSObject, ObservableObject{
    
    @Published var sensorData = [[String:Any]]()
    @Published var fileURL: URL? = nil

    var healthKitManager = HealthKitManager()
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(motionManager(notification:)), name: .didUpdateSensorDate, object: nil)
        
    }
    
    @objc func motionManager(notification: Notification){
        //        DispatchQueue.main.async {
        guard let data = notification.object as? [[String:Any]] else { return }
        print("DEBUG  input data \(data)")
        self.sensorData = data
        self.convertToCSV()
    }
    
    func startWorkout(){
        healthKitManager.startWorkout()
    }
    
    func stopWorkout(){
        healthKitManager.stopWorkout()
    }
    
    // File
    
    
    func convertToCSV(){
        
        var csvText = "ID,Logging time,Activity,UserAcceleration_x,UserAcceleration_y,UserAcceleration_z,Rotation_x,Rotation_y,Rotation_z,Roll,Pitch,Yaw,Gravity_x,Gravity_y,Gravity_z \n"
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatterGet.string(from: Date())
        let fileName = "ActivityData_" + "\(dateString)" + ".csv"
        
        for dict in self.sensorData {
            let newLine = "\(dict["id"] ?? 99),\(dict["date"] ?? dateString),\(dict["activity"] ?? "unkown"),\(dict["userAcceleration_x"] ?? 0),\(dict["userAcceleration_y"] ?? 0),\(dict["userAcceleration_z"] ?? 0),\(dict["rotation_x"] ?? 0),\(dict["rotation_y"] ?? 0),\(dict["rotation_z"] ?? 0),\(dict["roll"] ?? 0),\(dict["pitch"] ?? 0),\(dict["yaw"] ?? 0),\(dict["gravity_x"] ?? 0),\(dict["gravity_y"] ?? 0),\(dict["gravity_z"] ?? 0)" + "\n"
            csvText.append(newLine)
        }
        
        let url = self.getDocumentsDirectory().appendingPathComponent(fileName)
        
        print("\(Date()) data : \(csvText)")
        do {
            try csvText.write(to: url, atomically: true, encoding: .utf8)
            self.fileURL = url
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
}


extension Notification.Name{
    
    static let didUpdateSensorDate = Notification.Name("didUpdateSensorDate")
    
}
