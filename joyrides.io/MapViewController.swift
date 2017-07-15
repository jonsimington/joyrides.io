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

class MapViewController: UIViewController,
                         MKMapViewDelegate,
                         UIAlertViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet var currentlyRecordingIndicator: UIImageView!
    
    var locationManager = CLLocationManager()
    
    var recording = false
    
    var lastUpdated = Date()
    
    @IBAction func recordButtonOnClick(_ sender: Any) {
        
        self.locationManager = CLLocationManager()
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if (recording) {
            locationManager.stopUpdatingLocation()
            print("stopped updating loc")
            recording = false
            currentlyRecordingIndicator.isHidden = !recording
        }
        else {
            locationManager.startUpdatingLocation()
            print("Started updating loc")
            recording = true
            currentlyRecordingIndicator.isHidden = !recording
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 38.57, longitude: -90.55, zoom: 13.0)
        self.mapView.camera = camera
        
        self.mapView.isMyLocationEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    
    
    func determineMyCurrentLocation() {
        self.locationManager = CLLocationManager()
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let lat = userLocation.coordinate.latitude
        let lon = userLocation.coordinate.longitude
        
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
    
    @IBOutlet var changeMapTypeButton: UIButton!
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
}

extension MapViewController: CLLocationManagerDelegate {
    
    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            print("THIS IS THE LOCATION \(location.coordinate.latitude)")
        }
        
        // This will stop updating the location.
        locationManager.stopUpdatingLocation()
        print("stopped updating location in updated loc")
    }
}

