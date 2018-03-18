//
//  Location.swift
//  CXE Reporter
//
//  Created by Muhammad Ali on 2/25/18.
//  Copyright © 2018 Customer Experience EcoSystem. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject {
    class GPS: NSObject, CLLocationManagerDelegate {
        static let shared = GPS()
        let locationManager = CLLocationManager()
        var hasAccess = false
        var location: CLLocation?
        
        var json: [String: Double] {
            if let latitude = self.location?.coordinate.latitude,
               let longitude = self.location?.coordinate.longitude {
                return [
                    "latitude": latitude,
                    "longitude": longitude
                ]
            }
            return [:]
        }

        override init() {
            super.init()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            self.setAvailability()
        }
        
        private func setAvailability() {
            if CLLocationManager.locationServicesEnabled() {
                let status = CLLocationManager.authorizationStatus()
                if status == .authorizedAlways || status == .authorizedWhenInUse {
                    self.hasAccess = true
                    return
                }
            }
            self.hasAccess = false
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                self.location = location
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            self.setAvailability()
        }
    }
    
    struct Specification {
        var title: String
        var options: [String]
    }
    
    var specifics: [Specification] = [
        Specification(
            title: "Terminal",
            options: [
                "terminal 1",
                "terminal 2",
                "terminal 3",
                "terminal 4",
                "terminal 5",
                ]
        ),
        Specification(
            title: "Gate",
            options: [
                "gate 1",
                "gate 2",
                "gate 3",
                "gate 4",
                "gate 5",
                ]
        ),
    ]
    
    private var selected: [String: Int] = [:]
    
    func currentSelected(for specification: Specification) -> Int? {
        return self.selected[specification.title]
    }
    
    func updateSelected(specification: Specification, with optionIndex: Int) {
        self.selected[specification.title] = optionIndex
    }
    
    func removeSelected(for specification: Specification) {
        self.selected.removeValue(forKey: specification.title)
    }
    
    var json: [String: Any] {
        return [
            "specifics": self.specificsJson,
            "gps": GPS.shared.json,
        ]
    }
    
    private var specificsJson: [String: String] {
        var dict: [String: String] = [:]
        for (title, optionIndex) in self.selected {
            if let options = self.specifics.options(for: title) {
                let option = options[optionIndex]
                dict[title] = option
            }
        }
        return dict
    }
    
    var specificsString: String {
        var str = ""
        for (title, option) in self.specificsJson {
            if str.isEmpty {
                str = title + " - " + option
            } else {
                str = str + ", " + title + " - " + option
            }
        }
        return str
    }
}

extension Location: HasToBeProvidedByTheUser {
    var notProvidedFields: [String] {
        var missing: [String] = []
        for specific in self.specifics {
            let keyExists = self.selected[specific.title] != nil
            if !keyExists {
                missing.append(specific.title)
            }
        }
        return missing
    }
    
    var isProvided: Bool {
        return self.notProvidedFields.isEmpty
    }
}

extension Sequence where Iterator.Element == Location.Specification {
    func options(for title: String) -> [String]? {
        for specifc in self {
            if specifc.title == title {
                return specifc.options
            }
        }
        return nil
    }
}
