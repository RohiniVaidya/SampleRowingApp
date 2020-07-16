//
//  ContentView.swift
//  SampleRowingApp
//
//  Created by Rohini Vaidya on 7/10/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var fileManager: PrivateFileManager
    @State private var showExportView = false
    
    var body: some View {
        
        VStack {
            
            HStack{
                Spacer()
                Circle()
                    .fill(self.fileManager.isReachable ? Color.green : Color.red)
                    .frame(width: 25, height: 25, alignment: .center)
                .padding()
            }
            Spacer()
            
            Text(fileManager.didRecieve ? "File Recieved" : "File Not Recieved")
            
            Spacer().frame(height: 50)
            
            if self.fileManager.didRecieve{
                Button("Export File"){
                    self.showExportView = true
                }
                .padding()
                .background(Color.black)
                .foregroundColor(Color.white)
            .cornerRadius(20)
                .sheet(isPresented: self.$showExportView) {
                    ExportFileView(activityItems: [self.fileManager.fileURL!])
                }
            }
            else{
                Button("Waiting for file"){
                    print("DEBUG: Waiting for file")
                }
                .padding()
                .background(Color.black)
                .foregroundColor(Color.white)
            .cornerRadius(20)
                .opacity(0.5)
            }
            Spacer()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

