//
//  HealthPermissions.swift
//  SampleRowingApp WatchKit Extension
//
//  Created by Rohini Vaidya on 7/10/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import Foundation
import HealthKit
import CoreMotion
import WatchKit
import WatchConnectivity

class HealthKitManager: NSObject {
    
    var healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    let motionManager = MotionManager()
    
    
    let typesToShare: Set = [
        HKQuantityType.workoutType()
    ]
    
    // The quantity types to read from the health store.
    let typesToRead: Set = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    ]
    
    // Request authorization for those quantity types.
    func requestPermission(){
        if HKHealthStore.isHealthDataAvailable(){
            self.healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (status, error) in
                if status{
                    
                    print("[DEBUG] healthkit authorized")
                    //                    self.workoutConfig()
                }
                else
                {
                    print("[ERROR] in auth perm \(error!)")
                }
            }
        }
        
    }
    
    func workoutConfig(){
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .rowing
//                configuration.locationType = .outdoor
        
        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            
            let builder = session.associatedWorkoutBuilder()
            session.delegate = self
            builder.delegate = self
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            self.session = session
            self.builder = builder
        } catch {
            // Handle failure here.
            return
        }
        
        
    }
    
    func startWorkout(){
        self.requestPermission()
        self.workoutConfig()
        guard let session = session, let builder = builder else { return  }
        let startDate = Date()
        
        
        session.startActivity(with: startDate)
        builder.beginCollection(withStart: startDate) { (success, error) in
            
            self.motionManager.startUpdates()
            
            if let error = error {
                print("Error starting HK builder collection: \(error)")
            }
        }
    }
    
    
    func stopWorkout(){
        guard let session = self.session else { return  }
        session.stopActivity(with: Date())
        
        session.end()
        guard let builder = self.builder else { return  }
        self.motionManager.stopUpdates()
        
        builder.endCollection(withEnd: Date(), completion: { (status, error) in
            builder.finishWorkout { (workout, error) in
                print("Energy", workout?.totalEnergyBurned as Any)
                print("Distance", workout?.totalDistance as Any)
            }
            print("[DEBUG] ended workout session")
        })
    }
    
  
    
}


extension HealthKitManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        
        //        print("****** Inside workout builder with collection types \(collectedTypes)")
        for type in collectedTypes {
            
            guard let quantityType = type as? HKQuantityType else {
                return
            }
            
            if let statistics = workoutBuilder.statistics(for: quantityType) {
                //                handleSendStatisticsData(statistics)
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
}

extension HealthKitManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("Workout Session state change: \(fromState.rawValue) -> \(toState.rawValue)")
        
        switch toState {
        case .notStarted: print("Workout session not started")
            
        case .prepared: print("Workout session prepared")
            
        case .running: print("Workout session started")
        if fromState == .paused {
            //                NotificationCenter.default.post(name: kResumeWorkoutNotification, object: nil)
            }
            
        case .paused: print("Workout session paused")
            //            NotificationCenter.default.post(name: kPauseWorkoutNotification, object: nil)
            
        case .stopped: print("Workout session stopped")
            
        case .ended: print("Workout session ended")
            //            NotificationCenter.default.post(name: kEndWorkoutNotification, object: nil)
            
        @unknown default: print("Unknown workout session state!")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        if let hkError = error as? HKError {
            if hkError.code == .errorAnotherWorkoutSessionStarted {
                stopWorkout()
                //                delegate?.didEndWorkoutWithInterruption()
            }
        }
        print("Failed:", error.localizedDescription)
    }
    
}
