//
//  WatchSessionHandler.swift
//  SampleRowingApp WatchKit Extension
//
//  Created by Rohini Vaidya on 7/16/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import Foundation
import WatchConnectivity


class WatchSessionHandler: NSObject, WCSessionDelegate{
    
    var session = WCSession.default
    static let shared = WatchSessionHandler()
    
    func initialize(){
        self.session.delegate = self
        self.session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .activationDidComplete, object: session.activationState.rawValue)
        }
        
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .reachabilityDidChange, object: session.isReachable)
        }
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //do something
    }
    
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        var transferData = TransferData()
        transferData.fileTransfer = fileTransfer
        
        if let error = error{
            transferData.errorMessage = error.localizedDescription
        }
    }
    
    func isReachable() -> Bool{
        
        if WCSession.default.isReachable{
            return true
        }
        return false
    }
    
    func sendMessage(message: [String: Any]){
        
        if self.session.isReachable{
            
            self.session.sendMessage(message, replyHandler: { (messageDict) in
                print("DEBUG: Successfully sent data")
            }) { (error) in
                print("ERROR: Error in sending data")
            }
        }
        
    }
    
    func updateApplicationContext(message: [String: Any]){
        do{
            try self.session.updateApplicationContext(message)
        }
        catch
        {
            print("Error: in updating")
        }
    }
    
    func transferFile(url: URL?){
        guard let url = url else { return }
        self.session.transferFile(url, metadata: nil)
    }
    
}


extension Notification.Name {
    
    static let activationDidComplete = Notification.Name("ActivationDidComplete")
    static let reachabilityDidChange = Notification.Name("ReachabilityDidChange")
    static let didRecieveFile = Notification.Name("didRecieveFile")

}


struct TransferData {
    
    var fileTransfer: WCSessionFileTransfer?
    var file: WCSessionFile?
    var errorMessage: String?
    
}
