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
    @Published var shouldReset: Bool = false
    
    
    
    
    var fileURL: URL?
    var sensorValues: [[String: Any]] = []
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(fileRecieved(notification:)), name: .didRecieveFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetRecieved), name: .resetReciever, object: nil)
        
        
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
        
        guard let url = notification.object as? URL else { return  }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {return}
        print("file: \(content)")
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatterGet.string(from: Date())
        let fileName = "ActivityData_" + "\(dateString)" + ".csv"
        
        let newURL = self.getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            try content.write(to: newURL, atomically: true, encoding: .utf8)
            self.fileURL = newURL
        } catch {
            print("Failed to create file")
            print("\(error)")
        }

        
    }
    
    @objc func resetRecieved(notification: Notification){
        DispatchQueue.main.async {
            self.didRecieve = false
            self.fileURL = nil
            self.sensorValues = []
        }
        
    }
    
    
    
    func convertToCSV(){
        
        var csvText = "ID,Logging time,Activity,UserAcceleration_x,UserAcceleration_y,UserAcceleration_z,Rotation_x,Rotation_y,Rotation_z,Roll,Pitch,Yaw,Gravity_x,Gravity_y,Gravity_z \n"
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatterGet.string(from: Date())
        let fileName = "ActivityData_" + "\(dateString)" + ".csv"

        for dict in self.sensorValues {
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
    
//    var fileURL: URL?
//    var sensorValues: [[String: Any]] = []
//
//    private var forwardFolderURL: URL?
//    private var backwardFolderURL: URL?
//
//    override init() {
//        super.init()
//
//        NotificationCenter.default.addObserver(self, selector: #selector(fileRecieved(notification:)), name: .didRecieveFile, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityDidChange, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(resetRecieved), name: .resetReciever, object: nil)
//
//
//    }
//
//    @objc func reachabilityChanged(notification: Notification){
//        DispatchQueue.main.async {
//            guard let status = notification.object as? Bool else {return}
//            self.isReachable = status
//        }
//
//    }
//
//    @objc func fileRecieved(notification: Notification){
//
//        DispatchQueue.main.async {
//            self.didRecieve = true
//        }
//        let receivedDictOfStrokes = notification.object as! [String:Any]
//        self.prepareFiles(strokesFilesData: receivedDictOfStrokes["forward"] as! [Any], folderName: "forward")
//        self.prepareFiles(strokesFilesData: receivedDictOfStrokes["backward"] as! [Any], folderName: "backward")
//
//    }
//
//    @objc func resetRecieved(notification: Notification){
//        DispatchQueue.main.async {
//            self.didRecieve = false
//            self.fileURL = nil
//            self.sensorValues = []
//        }
//
//    }
//
//    func prepareFiles(strokesFilesData: [Any], folderName: String) {
//        for i in 0..<strokesFilesData.count{
//            self.convertToCSV(with: strokesFilesData[i] as! [[String:Any]], with: folderName, index: i)
//
//        }
//
//    }
//
//    func convertToCSV(with fileContent: [[String:Any]], with folderName: String, index: Int){
//
//        //Header
//        var csvText = "Logging time,UserAcceleration_x,UserAcceleration_y,UserAcceleration_z,Rotation_x,Rotation_y,Rotation_z,roll,pitch,yaw,gravity_x,gravity_y,gravity_z \n"
//
//        //Time
//        let dateFormatterGet = DateFormatter()
//        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let dateString = dateFormatterGet.string(from: Date())
//
//
//        let fileName = "\(folderName)_" + "\(index)" + ".csv"
//
//        for dict in fileContent {
//            let newLine = "\(dict["date"] ?? dateString),\(dict["userAcceleration_x"] ?? 0),\(dict["userAcceleration_y"] ?? 0),\(dict["userAcceleration_z"] ?? 0),\(dict["rotation_x"] ?? 0),\(dict["rotation_y"] ?? 0),\(dict["rotation_z"] ?? 0),\(dict["roll"] ?? 0),\(dict["pitch"] ?? 0),\(dict["yaw"] ?? 0),\(dict["gravity_x"] ?? 0),\(dict["gravity_y"] ?? 0),\(dict["gravity_z"] ?? 0)" + "\n"
//            csvText.append(newLine)
//        }
//
//        let url = self.createDirectory(with: folderName).appendingPathComponent(fileName)
//
//        print("\(Date()) data : \(csvText)")
//        do {
//            try csvText.write(to: url, atomically: true, encoding: .utf8)
//            //                   self.fileURL = url
//        } catch {
//            print("Failed to create file")
//            print("\(error)")
//        }
//
//
//    }
//
//    func createDirectory(with folderName: String) -> URL{
//        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//        let documentsDirectory: AnyObject = paths[0] as AnyObject
//        let dataPath = documentsDirectory.appendingPathComponent(folderName)!
//        if folderName == "forward"{
//            self.forwardFolderURL = dataPath
//        }
//        else{
//            self.backwardFolderURL = dataPath
//        }
//        do {
//            try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: false, attributes: nil)
//
//        } catch let error as NSError {
//            print(error.localizedDescription);
//        }
//
//        print("DEBUG: folder path \(forwardFolderURL) and \(backwardFolderURL)")
//        return dataPath
//    }
//
//
//    func getDocumentsDirectory() -> URL {
//        // find all possible documents directories for this user
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//
//        // just send back the first one, which ought to be the only one
//        return paths[0]
//    }
}


