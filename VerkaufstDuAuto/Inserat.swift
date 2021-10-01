//
//  Inserat.swift
//  VerkaufstDuAuto
//
//  Created by Alpay Kücük on 23.09.21.
//

import Foundation
import UIKit
import FirebaseDatabase
import MapKit

class Inserat: NSObject, MKAnnotation {
    
    var id: String?
    var autoname: String?
    var preis: Int?
    var kilometerstand: Int?
    var baujahr: Int?
    var kraftstoff: String?
    var leistung: Int?
    var telefonnummer = ""
    var email = ""
    var instagram = ""
    var beschreibung = ""
    var gemerkt = false
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var latitude: Double?
    var longtitude: Double?

    var bilder = [Bild]()
    var bilderimages = [UIImage]()
    
    init(id: String, autoname: String, preis: Int, kilometerstand: Int, baujahr: Int, kraftstoff: String, leistung: Int, latitude: Double, longtitude: Double) {
        self.id = id
        self.autoname = autoname
        self.preis = preis
        self.kilometerstand = kilometerstand
        self.baujahr = baujahr
        self.kraftstoff = kraftstoff
        self.leistung = leistung
        self.latitude = latitude
        self.longtitude = longtitude
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)

    }
    
    func updateCoordinate() {
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longtitude!)
    }
    
    override init() {
        self.coordinate = CLLocationCoordinate2D(latitude: 20.0, longitude: 20.0)
    }
    
    
    init(snapshot: DataSnapshot) {
        let value = snapshot.value as? [String : AnyObject]
        self.id = value!["id"] as? String
        self.autoname = value!["autoname"] as? String
        self.preis = value!["preis"] as? Int
        self.kilometerstand = (value!["kilometerstand"] as? Int)!
        self.baujahr = value!["baujahr"] as? Int
        self.kraftstoff = value!["kraftstoff"] as? String
        self.leistung = value!["leistung"] as? Int
        self.telefonnummer = (value!["telefonnummer"] as? String)!
        self.email = (value!["email"] as? String)!
        self.instagram = (value!["instagram"] as? String)!
        self.beschreibung = (value!["beschreibung"] as? String)!
        self.gemerkt = (value!["gemerkt"] as? Bool)!
        self.latitude = value!["latitude"] as? Double
        self.longtitude = value!["longtitude"] as? Double
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longtitude!)
    }
    
}
