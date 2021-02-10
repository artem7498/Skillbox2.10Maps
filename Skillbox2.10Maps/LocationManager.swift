//
//  LocationManager.swift
//  Skillbox2.10Maps
//
//  Created by Артём on 2/8/21.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    typealias AccessRequestBlock = (Bool) -> ()
    typealias LocationRequestBlock = (CLLocationCoordinate2D?) -> ()
    
    var isEnabled: Bool { return CLLocationManager.isEnabled }
    var canRequestAccess: Bool { return CLLocationManager.canRequestService }
    
    private var accessRequestComplition: AccessRequestBlock?
    private var locationRequestComplition: LocationRequestBlock?
    
    private let locationManager = CLLocationManager()
    
    override init(){
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
    }
    
    func requestAccess(completion: AccessRequestBlock?){
        accessRequestComplition = completion
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getLocation(completion: LocationRequestBlock?){
        locationRequestComplition = completion
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate{
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        accessRequestComplition?(isEnabled)
    }
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        print(status)
//        accessRequestComplition?(isEnabled)
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location?.coordinate else {return}
        locationRequestComplition?(location)
        locationRequestComplition = nil
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        locationRequestComplition?(nil)
        locationRequestComplition = nil
    }
}

extension CLLocationManager{
    static var canRequestService: Bool{
        return authorizationStatus() != .restricted && authorizationStatus() != .denied
    }
    
    static var isEnabled: Bool{
        return authorizationStatus() == .authorizedAlways || authorizationStatus() == .authorizedWhenInUse
    }
}
