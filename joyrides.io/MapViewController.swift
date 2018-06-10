//
//  FirstViewController.swift
//  joyrides.io
//
//  Created by Jon on 7/7/17.
//  Copyright © 2017 jonsimington. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps

let NUM_SECONDS_IN_MINUTE = 60.0
let NUM_SECONDS_IN_HOUR = 3600.0


class MapViewController: UIViewController,
                         MKMapViewDelegate,
                         UIAlertViewDelegate,
                         CLLocationManagerDelegate {

    /////////////////////////////////////////////////////////////////////////////
    // 
    // IBOutlets & IBActions
    //
    /////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var currentlyRecordingIndicator: UIImageView!
    @IBOutlet var changeMapTypeButton: UIButton!
    @IBOutlet var driveTimerLabel: UILabel!
    @IBOutlet var completeDriveButton: UIButton!
    
    @IBOutlet var currentDriveStatsContainer: UIImageView!
    
    //////////////////////////////////
    //
    // SUB VIEWS
    //
    //////////////////////////////////
    @IBOutlet var driveStatsContainer: UIView!
    
    
    
    @IBAction func changeMapTypeButtonOnClick(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.mapView.mapType = GMSMapViewType(rawValue: 1)!
        }
        
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.mapView.mapType = GMSMapViewType(rawValue: 3)!
        }
        
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.mapView.mapType = GMSMapViewType(rawValue: 4)!
        }
        
        let satelliteMapTypeAction = UIAlertAction(title: "Satellite", style: UIAlertActionStyle.default) { (alertAction) -> Void in
            self.mapView.mapType = GMSMapViewType(rawValue: 2)!
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(satelliteMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        show(actionSheet, sender: self)
    }
    
    @IBAction func recordButtonOnClick(_ sender: Any) {
        // if we are recording, we should stop
        if (recording) {
            // stop timer
            stopTimer(driveTimer)
            
            // stop updating location
            locationManager.stopUpdatingLocation()
            print("stopped updating loc")
            recording = false
            currentlyRecordingIndicator.isHidden = !recording
            
            // calculate time diff
            let startTime = visited[0].timestamp
            let stopTime = visited.last?.timestamp
            let diff = stopTime?.seconds(from: startTime)
            
            // calculate dist traveled
            let distTraveled = totalDistTraveledInDrive(locs: visited)
            
            print("Gathered \(visited.count) locs in \(diff!) s and traveled \(distTraveled) ft")
        }
        // else we start recording
        else {
            // show stats container
            driveStatsContainer.isHidden = false
            
            // start timer
            startTimer(driveTimer)
            
            // start updating location
            locationManager.startUpdatingLocation()
            print("Started updating loc")
            recording = true
            currentlyRecordingIndicator.isHidden = !recording
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////
    //
    // View Local Variables
    //
    /////////////////////////////////////////////////////////////////////////////
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    var recording = false
    var lastUpdated = Date()
    var visited = [Loc]()
    var timeElapsed = 0.0
    var driveTimer = Timer()
    var isPlaying = false
    
    /////////////////////////////////////////////////////////////////////////////
    //
    // Location Funcs
    //
    /////////////////////////////////////////////////////////////////////////////
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.isMyLocationEnabled = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let lat = userLocation.coordinate.latitude
        let lon = userLocation.coordinate.longitude
        
        let vistedLoc = Loc(lat:lat, lon:lon, timestamp: Date())
        
        visited.append(vistedLoc)
        
        mapView.camera = GMSCameraPosition.camera(withTarget: userLocation.coordinate, zoom: 13.0)
        
        print("user latitude = \(lat)")
        print("user longitude = \(lon)")
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        marker.map = mapView
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }

    
    func determineMyCurrentLocation(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) -> CLLocation {
        let myLocation: CLLocation = locations[0] as CLLocation
        return myLocation
    }
    
    func totalDistTraveledInDrive(locs: [Loc]) -> Double {
        var totalDist = 0.0
        
        for i in 1..<locs.count {
            let dist = kmToFeet(km: distanceInKmBetweenEarthCoordinates(loc1: locs[i], loc2: locs[i-1]))
            totalDist += dist
        }
        
        print("Total Dist: \(totalDist)")
        
        return totalDist
    }
    
    func startTimer(_ sender: AnyObject) {
        if(isPlaying) {
            return
        }
        
        driveTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        isPlaying = true
    }
    
    func stopTimer(_ sender: AnyObject) {
        driveTimer.invalidate()
        isPlaying = false
    }
    
    func resetTimer(_ sender: AnyObject) {
        driveTimer.invalidate()
        isPlaying = false
        timeElapsed = 0.0
        driveTimerLabel.text = String(timeElapsed) + " s"
    }
    
    @objc func UpdateTimer() {
        timeElapsed = timeElapsed + 0.1
        driveTimerLabel.text = prettyTimeDiff(seconds: timeElapsed)
    }
    
    func prettyTimeDiff(seconds: Double) -> String {
        var hasSeconds = false
        var hasMinutes = false
        var hasHours = false
        
        var hoursDiff = 0
        var minutesDiff = 0
        var secondsDiff = seconds
        
        var diffString = ""
        
        // check for hours first
        if(seconds > NUM_SECONDS_IN_HOUR) {
            hasHours = true
            
            let numHours = seconds / NUM_SECONDS_IN_HOUR
            hoursDiff = Int(numHours)
            
            var remainderSeconds = (numHours - Double(hoursDiff)) * NUM_SECONDS_IN_HOUR
            
            // check if we still have minutes left
            if(remainderSeconds >= NUM_SECONDS_IN_MINUTE) {
                hasMinutes = true
                let numMinutes = remainderSeconds / NUM_SECONDS_IN_MINUTE
                minutesDiff = Int(numMinutes)
                
                remainderSeconds = (numMinutes - Double(minutesDiff)) * NUM_SECONDS_IN_MINUTE
                
                if(remainderSeconds > 0) {
                    hasSeconds = true
                    secondsDiff = remainderSeconds
                }
                else {
                    hasSeconds = false
                }
            }
        }
        // if not hours, check for minutes
        else if(seconds > NUM_SECONDS_IN_MINUTE) {
            hasMinutes = true
            
            let numMinutes = seconds / NUM_SECONDS_IN_MINUTE
            minutesDiff = Int(numMinutes)
            
            let remainderSeconds = (numMinutes - Double(minutesDiff)) * NUM_SECONDS_IN_MINUTE
            
            if(remainderSeconds > 0) {
                hasSeconds = true
                secondsDiff = remainderSeconds
            }
            else {
                hasSeconds = false
            }
        }
        // if not minutes, check for seconds
        else if(seconds > 0) {
            hasSeconds = true
        }
        
        // hours, mins, seconds, or hours seconds cases
        if(hasHours) {
            diffString = "\(hoursDiff) h"
            
            if(hasMinutes) {
                diffString += " \(minutesDiff) m"
                
                if(hasSeconds) {
                    diffString += String(format: " %.01f s",secondsDiff)
                }
            }
            else if(hasSeconds) {
                diffString += String(format: " %.01f s",secondsDiff)
            }
        }
        // mins, seconds case
        else if(hasMinutes) {
            diffString += " \(minutesDiff) m"
            
            if(hasSeconds) {
                diffString += String(format: " %.01f s",secondsDiff)
            }
        }
        // seconds only case
        else if(hasSeconds) {
            diffString += String(format: " %.01f s",secondsDiff)
        }
        
        return diffString
    }

    /////////////////////////////////////////////////////////////////////////////
    //
    // View Funcs
    //
    /////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // complete drive button should be hidden
        //completeDriveButton.isHidden = true
        
        // init timer
        resetTimer(driveTimer)
        
        self.locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        // init location
        locationManager.startUpdatingLocation()
        sleep(2)
        locationManager.stopUpdatingLocation()
        
        self.mapView.isMyLocationEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}



