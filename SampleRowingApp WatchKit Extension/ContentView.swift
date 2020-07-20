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
    
    var workoutsHandler = HealthKitManager()
    
    @ObservedObject var reachabilitymanager = Reachabilitymanager()
    @State private var workoutInProgress = false
    
    var body: some View {
        VStack{
            if workoutInProgress{
                
                VStack{
                    Text("Workout in Progress")
                    
                    Spacer()
                    
                    Button(action: {
                        self.workoutInProgress = false
                        self.workoutsHandler.stopWorkout()
                    }, label: {
                        Text("End Workout")
                    })
                    
                }
                
                
            }
            else {
                
                VStack{
                    Button("Request Permission"){
                        self.workoutsHandler.requestPermission()
                    }
                    Button(action: {
                        self.workoutsHandler.startWorkout()
                        self.workoutInProgress = true
                    }, label: {
                        Text("Start Workout")
                    })
                    
                    
                }
                
            }
            
            
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
