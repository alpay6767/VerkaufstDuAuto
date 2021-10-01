//
//  AutoDetailsView.swift
//  VerkaufstDuAuto
//
//  Created by Alpay Kücük on 25.09.21.
//

import Foundation
import UIKit
import ImageSlideshow
import FirebaseDatabase
import MapKit

class AutoDetailsView: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var imageslideshow: ImageSlideshow!
    
    let locationManager = CLLocationManager()
    var currentLongtitude = 20.0
    var currentLatitude = 20.0
    
    @IBOutlet weak var preis: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var kilometerstand: UILabel!
    @IBOutlet weak var kraftstoff: UILabel!
    @IBOutlet weak var baujahr: UILabel!
    @IBOutlet weak var leistung: UILabel!
    @IBOutlet weak var beschreibung: UITextView!
    
    @IBOutlet weak var merkenbtn: UIBarButtonItem!
    var selectedInserat: Inserat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageslideshow.setImageInputs(getListOfImageSources(bildliste: selectedInserat!.bilder))
        imageslideshow.contentScaleMode = .scaleAspectFill
        name.text = selectedInserat?.autoname
        preis.text = (selectedInserat?.preis!.description)! + "€"
        kraftstoff.text = selectedInserat?.kraftstoff
        kilometerstand.text = (selectedInserat?.kilometerstand!.description)! + " KM"
        baujahr.text = selectedInserat?.baujahr?.description
        leistung.text = (selectedInserat?.leistung!.description)! + " PS"
        beschreibung.text = selectedInserat?.beschreibung
        if (selectedInserat!.gemerkt) {
            merkenbtn.image = UIImage(systemName: "star.fill")
        } else {
            merkenbtn.image = UIImage(systemName: "star")
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        currentLatitude = locValue.latitude
        currentLongtitude = locValue.longitude
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    @IBAction func merken(_ sender: Any) {
        var ref: DatabaseReference!
        ref = Database.database(url: "https://challenges-cfbd3-default-rtdb.europe-west1.firebasedatabase.app").reference()
        ref.child("Inserate").child(selectedInserat!.id!).child("gemerkt").setValue(!selectedInserat!.gemerkt)
        selectedInserat?.gemerkt = !selectedInserat!.gemerkt
        
        if (selectedInserat!.gemerkt) {
            merkenbtn.image = UIImage(systemName: "star.fill")
        } else {
            merkenbtn.image = UIImage(systemName: "star")
        }
    }
    
    @IBAction func interesed(_ sender: Any) {
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        
        self.locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        let alert = UIAlertController(title: "Kontaktieren", message: "Wie möchten Sie den Verkäufer kontaktieren?", preferredStyle: .actionSheet)
            
        if selectedInserat?.telefonnummer != "" {
            alert.addAction(UIAlertAction(title: "Anrufen", style: .default , handler:{ (UIAlertAction)in
                self.makeAPhoneCall(nummer: (self.selectedInserat?.telefonnummer)!)
            }))
        }
        if selectedInserat?.email != "" {
            alert.addAction(UIAlertAction(title: "E-Mail schreiben", style: .default , handler:{ (UIAlertAction)in
                self.makeemail(email: self.selectedInserat!.email)
            }))
        }
        if selectedInserat?.instagram != "" {
            alert.addAction(UIAlertAction(title: selectedInserat!.instagram + " auf Insta schreiben", style: .default, handler:{ (UIAlertAction)in
                self.openinsta(insta: self.selectedInserat!.instagram)
            }))
        }
                
        alert.addAction(UIAlertAction(title: "Navigieren", style: .default , handler:{ (UIAlertAction)in
            self.navigieren()
            }))
        
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel , handler:{ (UIAlertAction)in
            alert.dismiss(animated: true) {
                
            }
        }))
  
        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view

        self.present(alert, animated: true, completion: {
        })
        
    }
    @IBAction func sharebtn(_ sender: Any) {
    }
    
    func getListOfImageSources(bildliste: [Bild]) -> [InputSource] {
        var imageliste = [InputSource]()
        for currentbild in bildliste {
            let inputsource = KingfisherSource(urlString: currentbild.bildurl!)
            imageliste.append(inputsource!)
        }
        return imageliste
    }
    
    func makeAPhoneCall(nummer: String)  {
        guard let url = URL(string: "tel://\(nummer)") else {
        return //be safe
        }

        if #available(iOS 10.0, *) {
        UIApplication.shared.open(url)
        } else {
        UIApplication.shared.openURL(url)
        }
    }
    
    func makeemail(email: String) {
        let appURL = URL(string: "mailto:" + email)!

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appURL)
        }
    }
    
    func openinsta(insta: String) {
        var instagramHooks = "instagram://user?username=" + insta
        var instagramUrl = NSURL(string: instagramHooks)
        if UIApplication.shared.canOpenURL(instagramUrl! as URL) {
            UIApplication.shared.openURL(instagramUrl! as URL)
        } else {
          //redirect to safari because the user doesn't have Instagram
            UIApplication.shared.openURL(NSURL(string: "http://instagram.com/")! as URL)
        }
    }
    
    func navigieren() {
        let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()

        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongtitude)))
        source.name = "Ich"

        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: selectedInserat!.latitude!, longitude: selectedInserat!.longtitude!)))
        destination.name = selectedInserat!.autoname!

        MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
}
