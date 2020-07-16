//
//  ReachabilityManager.swift
//  SampleRowingApp WatchKit Extension
//
//  Created by Rohini Vaidya on 7/16/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import Foundation

class Reachabilitymanager: NSObject, ObservableObject {
    
    
    @Published var notReachable = false
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(notification:)), name: .reachabilityDidChange, object: nil)
        
    }
    
    @objc func reachabilityDidChange(notification: Notification){
        guard let status = notification.object as? Bool else { return  }
        DispatchQueue.main.async {
            if !status{
                self.notReachable = true

            }
        }
        
    }
}
