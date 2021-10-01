//
//  KontaktdatenView.swift
//  VerkaufstDuAuto
//
//  Created by Alpay Kücük on 24.09.21.
//

import Foundation
import UIKit
import FirebaseDatabase
import BLTNBoard

class KontaktdatenView: UIViewController {
    
    var bulletinManager: BLTNItemManager?

    @IBOutlet weak var telefonnummer: UITextField!
    @IBOutlet weak var instagramname: UITextField!
    @IBOutlet weak var emailadresse: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
    }
    
    @IBAction func reinstellen(_ sender: Any) {
        
        inseratEinstellen {
            self.bulletinManager = BLTNItemManager(rootItem: createBulletinBoardItemForVerkaufen(title: "Inserat erstellt!", description: "Dein Auto steht nun zum kaufen bereit!", buttontext: "Nice!", image: #imageLiteral(resourceName: "eingestellt")))
            self.bulletinManager!.showBulletin(above: self)
            
        }
        
    }
    
    func createBulletinBoardItemForVerkaufen(title: String, description: String, buttontext: String, image: UIImage) -> BLTNItem {
        let page = BLTNPageItem(title: title)
        page.image = image
        
        page.descriptionText = description
        page.actionButtonTitle = buttontext
        page.actionHandler = { (item: BLTNActionItem) in
            item.manager?.dismissBulletin(animated: true)
            self.navigationController?.popToRootViewController(animated: true)
        }
        let rootItem: BLTNItem = page
        
        return rootItem
    }
    
    func inseratEinstellen(finished: () -> Void) {
        var ref: DatabaseReference!
        ref = Database.database(url: "https://challenges-cfbd3-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
        
        let newinserat = VerkaufenView.currentinserat
        newinserat?.email = emailadresse.text!
        newinserat?.telefonnummer = telefonnummer.text!
        newinserat?.instagram = instagramname.text!
        
        ref?.child("Inserate").child(newinserat!.id!).setValue([
            "id" : newinserat!.id!,
            "autoname" : newinserat!.autoname!,
            "preis" : newinserat!.preis!,
            "kilometerstand" : newinserat!.kilometerstand!,
            "baujahr" : newinserat!.baujahr!,
            "kraftstoff" : newinserat!.kraftstoff!,
            "leistung" : newinserat!.leistung!,
            "telefonnummer" : newinserat!.telefonnummer,
            "email" : newinserat!.email,
            "instagram" : newinserat!.instagram,
            "beschreibung" : newinserat!.beschreibung,
            "gemerkt" : false,
            "latitude" : newinserat!.latitude,
            "longtitude" : newinserat!.longtitude
        ])
        
        for currentbild in newinserat!.bilderimages {
            var ref: DatabaseReference!
            ref = Database.database(url: "https://challenges-cfbd3-default-rtdb.europe-west1.firebasedatabase.app").reference()
            let newid = ref.child("Inserate").child(newinserat!.id!).child("Bilder").childByAutoId().key
            let currentCreatedBild = Bild(id: newid!, uiimage: currentbild, bildurl: "")
            
            let fbhandler = FBHandler()
            
            fbhandler.uploadMedia(image: currentbild, currentinserat: newinserat!, currentBild: currentCreatedBild) { url in
                 guard let url = url else { return }
                currentCreatedBild.bildurl = url
                ref?.child("Inserate").child(newinserat!.id!).child("Bilder").child(currentCreatedBild.id!).setValue([
                    "id" : currentCreatedBild.id,
                    "bildurl" : currentCreatedBild.bildurl
                ])
                
            }
        }
        
        finished()
        
    }
    
}

