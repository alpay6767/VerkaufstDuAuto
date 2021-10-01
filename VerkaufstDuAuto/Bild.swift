//
//  Bild.swift
//  VerkaufstDuAuto
//
//  Created by Alpay Kücük on 25.09.21.
//

import Foundation
import UIKit
import FirebaseDatabase


class Bild {
    
    var uiimage: UIImage?
    var id: String?
    var bildurl: String?
    
    init(id: String, uiimage: UIImage, bildurl: String) {
        self.id = id
        self.uiimage = uiimage
        self.bildurl = bildurl
    }
    
    init(snapshot: DataSnapshot) {
        let value = snapshot.value as? [String : AnyObject]
        self.id = value!["id"] as? String
        self.bildurl = value!["bildurl"] as? String
    }
    
}
