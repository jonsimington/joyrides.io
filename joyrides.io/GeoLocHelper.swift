//
//  GeoLocHelper.swift
//  joyrides.io
//
//  Created by Jon Simington on 7/14/17.
//  Copyright © 2017 jonsimington. All rights reserved.
//

import Foundation

func degreesToRadians(degrees: Double) -> Double {
    return degrees * M_PI / 180;
}

func distanceInKmBetweenEarthCoordinates(loc1: Loc, loc2: Loc) -> Double {
    let earthRadiusKm = 6371.0;
    
    let dLat = degreesToRadians(degrees: loc2.lat-loc1.lat);
    let dLon = degreesToRadians(degrees: loc2.lon-loc1.lon);
    
    let lat1 = degreesToRadians(degrees: loc1.lat);
    let lat2 = degreesToRadians(degrees: loc2.lat);
    
    let a = sin(dLat/2) * sin(dLat/2) +
        sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2);
    let c = 2 * atan2(sqrt(a), sqrt(1-a));
    return earthRadiusKm * c;
}

func kmToFeet(km: Double) -> Double {
    return km * 3280.84
}
