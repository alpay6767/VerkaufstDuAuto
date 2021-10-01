//
//  VerkaufenView.swift
//  VerkaufstDuAuto
//
//  Created by Alpay Kücük on 23.09.21.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import FirebaseDatabase
import BLTNBoard
import MapKit

class VerkaufenView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    let kraftstofflist = ["Benzin", "Diesel", "Hyrbid", "Elektro"]
    
    var selectedKraftstoff = "Benzin"
    
    static var currentinserat: Inserat?
    let locationManager = CLLocationManager()

    var currentLongtitude = 20.0
    var currentLatitude = 20.0
    
    var bulletinManager: BLTNItemManager?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return kraftstofflist[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedKraftstoff = kraftstofflist[row]
    }
    
    func inkrement(zahl: inout Int){
        
        zahl+=1
        
    }
    

    @IBOutlet weak var gewünschterpreis: UITextField!
    @IBOutlet weak var autoname: UITextField!
    @IBOutlet weak var kraftstoff_picker: UIPickerView!
    @IBOutlet weak var baujahr: UITextField!
    @IBOutlet weak var kilometerstand: UITextField!
    @IBOutlet weak var leistung: UITextField!
    @IBOutlet weak var beschreibung: UITextView!
    @IBOutlet weak var verkaufenbtn: UIButton!
    
    @IBAction func verkaufen(_ sender: Any) {
        if isEmpty() {
            // HINT: do nothing
        } else {
            
            inseratEinstellen {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "bildwaehlen")
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        currentLatitude = locValue.latitude
        currentLongtitude = locValue.longitude
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        kraftstoff_picker.delegate = self
        kraftstoff_picker.dataSource = self
        beschreibung.layer.cornerRadius = 15
        beschreibung.clipsToBounds = true

        
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
        
    }
    
    func inseratEinstellen(finished: () -> Void) {
        var ref: DatabaseReference!
        ref = Database.database(url: "https://challenges-cfbd3-default-rtdb.europe-west1.firebasedatabase.app").reference()
        let newid = ref.child("Inserate").childByAutoId().key
                
        
        
        let newinserat = Inserat(id: newid!, autoname: autoname.text!, preis: Int(gewünschterpreis.text!)!, kilometerstand: Int(kilometerstand.text!)!, baujahr: Int(baujahr.text!)!, kraftstoff: selectedKraftstoff, leistung: Int(leistung.text!)!, latitude: currentLatitude, longtitude: currentLongtitude)
        
        if beschreibung.text! != "Hier kannst du extra nochmal dein Auto beschreiben und bisschen Werbung machen!" {
            newinserat.beschreibung = beschreibung.text!
        }
        VerkaufenView.currentinserat = newinserat

        finished()
       
    }
    
    func isEmpty() -> Bool {
        
        if (autoname.text == "" || gewünschterpreis.text == "" || baujahr.text == "" || leistung.text == "") {
            return true
        } else {
            return false
        }
        
    }
    
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func createBulletinBoardItem(title: String, description: String, buttontext: String, image: UIImage) -> BLTNItem {
        let page = BLTNPageItem(title: title)
        page.image = image
        
        page.descriptionText = description
        page.actionButtonTitle = buttontext
        page.actionHandler = { (item: BLTNActionItem) in
            item.manager?.dismissBulletin(animated: true)
        }
        let rootItem: BLTNItem = page
        
        return rootItem
    }
    
}
