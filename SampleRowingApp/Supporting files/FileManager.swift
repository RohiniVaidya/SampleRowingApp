//
//  FileManager.swift
//  SampleRowingApp
//
//  Created by Rohini Vaidya on 7/16/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import Foundation


class PrivateFileManager: NSObject, ObservableObject{
    @Published var didRecieve: Bool = false
    @Published var isReachable: Bool = false

    
    var fileURL: URL?
    var sensorValues: [[String: Any]] = []
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(fileRecieved(notification:)), name: .didRecieveFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityDidChange, object: nil)

    }
    
    @objc func reachabilityChanged(notification: Notification){
         DispatchQueue.main.async {
            guard let status = notification.object as? Bool else {return}
            self.isReachable = status
        }
        
    }
    
    @objc func fileRecieved(notification: Notification){
        
        DispatchQueue.main.async {
            self.didRecieve = true
        }
        self.sensorValues = notification.object as! [[String:Any]]

        self.convertToCSV()

    }
    
    
    func convertToCSV(){
        let fileName = "ActivityData.csv"
        
        var csvText = "Date,UserAcceleration_x,UserAcceleration_y,UserAcceleration_z,Rotation_x,Rotation_y,Rotation_z \n\n"
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatterGet.string(from: Date())
        
        for dict in self.sensorValues {
            let newLine = "\(dict["Date"] ?? dateString), \(dict["userAcceleration_x"] ?? 0),\(dict["userAcceleration_y"] ?? 0),\(dict["userAcceleration_z"] ?? 0),\(dict["rotation_x"] ?? 0),\(dict["rotation_y"] ?? 0),\(dict["rotation_z"] ?? 0)" + "\n\n"
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


