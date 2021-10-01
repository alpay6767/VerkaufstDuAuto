//
//  SuchenView.swift
//  VerkaufstDuAuto
//
//  Created by Alpay Kücük on 23.09.21.
//

import Foundation
import UIKit
import ImageSlideshow
import Kingfisher

class SuchenView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var suchenbtn: UIButton!
    @IBOutlet weak var inserate_cv: UICollectionView!
    private let refreshControl = UIRefreshControl()

    
    let fbhandler = FBHandler()
    var inserateliste = [Inserat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBarImage()
        inserate_cv.delegate = self
        inserate_cv.dataSource = self
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
            inserate_cv.alwaysBounceVertical = true
            inserate_cv.refreshControl = refreshControl // iOS 10+
        loadInserate()
        
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        // Do you your api calls in here, and then asynchronously remember to stop the
        // refreshing when you've got a result (either positive or negative)
        loadInserate()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inserateliste.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 400)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inseratecell", for: indexPath) as! InserateCell
        
        let currentinserat = inserateliste[indexPath.item]
        cell.name.text = currentinserat.autoname
        cell.kilometerstand.text = currentinserat.kilometerstand!.description + " KM"
        cell.baujahr.text = currentinserat.baujahr?.description
        cell.kraftstoff.text = currentinserat.kraftstoff
        cell.leistung.text = currentinserat.leistung!.description + " PS"
        cell.preis.text = currentinserat.preis!.description + "€"
        cell.imageslideshow.setImageInputs(getListOfImageSources(bildliste: currentinserat.bilder))
        cell.imageslideshow.contentScaleMode = .scaleAspectFill
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentinserat = inserateliste[indexPath.item]
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "autodetailsview") as! AutoDetailsView
        newViewController.selectedInserat = currentinserat
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func getListOfImageSources(bildliste: [Bild]) -> [InputSource] {
        var imageliste = [InputSource]()
        for currentbild in bildliste {
            var inputsource = KingfisherSource(urlString: currentbild.bildurl!)
            imageliste.append(inputsource!)
        }
        return imageliste
    }
    
    func loadInserate() {
        
        fbhandler.loadInserate() { inseratlist in
             guard let inseratlist = inseratlist else { return }
                
            self.inserateliste
                = inseratlist
            //self.gruppenlist.reverse()
            self.inserate_cv.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func suchen_pressed(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "maptab") as! mapTab
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func addNavBarImage() {

        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 30))

         let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 270, height: 30))
         imageView.contentMode = .scaleAspectFit
         let image = #imageLiteral(resourceName: "logo")
         imageView.image = image
         logoContainer.addSubview(imageView)
         navigationItem.titleView = logoContainer
        }
}
