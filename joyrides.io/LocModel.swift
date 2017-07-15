//
//  LocModel.swift
//  joyrides.io
//
//  Created by Jon Simington on 7/14/17.
//  Copyright © 2017 jonsimington. All rights reserved.
//

import Foundation

class Loc {
    var lat = Double()
    var lon = Double()
    var timestamp = Date()
    
    init(lat:Double,
         lon:Double,
         timestamp:Date) {
        self.lat = lat
        self.lon = lon
        self.timestamp = timestamp
    }
}
