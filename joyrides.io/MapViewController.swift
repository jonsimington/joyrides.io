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

class MapViewController: UIViewController,
                         MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var statusBar: UILabel!
    
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet var currentlyRecordingIndicator: UIImageView!
    
    @IBOutlet var latLonStatusLabel: UILabel!
    
    var locationManager = CLLocationManager()
    
    var recording = false
    
    var lastUpdated = Date()
    
    @IBAction func recordButtonOnClick(_ sender: Any) {
        statusBar.text = "Status:   Recording Drive"
        
        self.locationManager = CLLocationManager()
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if (recording) {
            locationManager.stopUpdatingLocation()
            print("stopped updating loc")
            statusBar.text = "Status:   Stopped Recording"
            recording = false
            currentlyRecordingIndicator.isHidden = !recording
        }
        else {
            locationManager.startUpdatingLocation()
            print("Started updating loc")
            statusBar.text = "Status:   Started Recording"
            recording = true
            currentlyRecordingIndicator.isHidden = !recording
        }
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
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
        
        statusBar.text = "Status:   Updated Location"
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let lat = userLocation.coordinate.latitude
        let lon = userLocation.coordinate.longitude
        
        latLonStatusLabel.text = "\(lat), \(lon)"
        
        print("user latitude = \(lat)")
        print("user longitude = \(lon)")
        
        let latDelta:CLLocationDegrees = 0.01
        let lonDelta:CLLocationDegrees = 0.01
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        
        lastUpdated = Date()
        
        annotation.coordinate = location
        annotation.title = "Your Location \(lastUpdated)"
        annotation.subtitle = "\(lat), \(lon)"
        mapView.addAnnotation(annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
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

