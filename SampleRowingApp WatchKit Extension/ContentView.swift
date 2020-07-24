//
//  ContentView.swift
//  SampleRowingApp WatchKit Extension
//
//  Created by Rohini Vaidya on 7/10/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
    @EnvironmentObject var interactor: Interactor
        
    @State private var workoutInProgress = false
    
    var body: some View {
        VStack{
            if workoutInProgress{
                
                Text("Workout in Progress")
                
                Spacer()
                
                Button(action: self.performStopWorkout){
                    Text("End Workout")
                }
                
            }
            else {
                Button(action: self.performStartWorkout){
                    Text("Start Workout")
                }
                
            }
            
            
        }
    }
    
    
    func performStartWorkout(){
        WatchSessionHandler.shared.sendMessage(message: ["reset": "true"])

        self.interactor.startWorkout()
        self.workoutInProgress = true
        
    }
    
    
    func performStopWorkout(){
        
        self.workoutInProgress = false
        self.interactor.stopWorkout()
        print("DEBUG in view \(self.interactor.fileURL!)")
//        WatchSessionHandler.shared.sendMessage(message: ["sensorvalues": self.interactor.sensorData])
        WatchSessionHandler.shared.transferFile(url: self.interactor.fileURL!)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
