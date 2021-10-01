//
//  InserateCell.swift
//  VerkaufstDuAuto
//
//  Created by Alpay Kücük on 25.09.21.
//

import Foundation
import UIKit
import ImageSlideshow

class InserateCell: UICollectionViewCell {
    
    @IBOutlet weak var imageslideshow: ImageSlideshow!
    
    @IBOutlet weak var preis: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var kilometerstand: UILabel!
    @IBOutlet weak var kraftstoff: UILabel!
    @IBOutlet weak var baujahr: UILabel!
    @IBOutlet weak var leistung: UILabel!
    
}
