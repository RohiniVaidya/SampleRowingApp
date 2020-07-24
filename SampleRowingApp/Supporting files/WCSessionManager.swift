//
//  WCSessionManager.swift
//  SampleRowingApp
//
//  Created by Rohini Vaidya on 7/16/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import Foundation
import WatchConnectivity


class WCSessionManager: NSObject, WCSessionDelegate{
    
    static let shared = WCSessionManager()
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith")
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        NotificationCenter.default.post(name: .reachabilityDidChange, object: session.isReachable)
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let status = applicationContext["reset"] as? Bool{
            if status{
                NotificationCenter.default.post(name: .resetReciever, object: true)
                
            }
            
        }
    }
    
    //    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    //
    //    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        if let status = message["reset"] as? String{
            if status == "true"{
                NotificationCenter.default.post(name: .resetReciever, object: true)
                
            }
            
        }
        if message["sensorvalues"] as? [[String: Any]] != nil{
            NotificationCenter.default.post(name: .didRecieveFile, object: message["sensorvalues"])
        }
        
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("file recieved \(file)")
        
        NotificationCenter.default.post(name: .didRecieveFile, object: file.fileURL)

    }
    
}


extension Notification.Name {
    
    static let reachabilityDidChange = Notification.Name("ReachabilityDidChange")
    static let didRecieveFile = Notification.Name("didRecieveFile")
    static let resetReciever = Notification.Name("resetReciever")
    
}
