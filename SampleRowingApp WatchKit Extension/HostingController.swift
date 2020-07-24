//
//  HostingController.swift
//  SampleRowingApp WatchKit Extension
//
//  Created by Rohini Vaidya on 7/10/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
        
    override var body: AnyView {
        return AnyView(ContentView().environmentObject(Interactor()))
    }
}
