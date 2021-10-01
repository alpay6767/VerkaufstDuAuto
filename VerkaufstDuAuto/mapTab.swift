//
//  mapTab.swift
//  Mapr
//
//  Created by Alpay Kücük on 18.11.20.
//

import Foundation
import UIKit
import MapKit
import Kingfisher
import FirebaseDatabase

class mapTab: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapview: MKMapView!
    var manager = CLLocationManager()
    
    var locationManager = CLLocationManager()

    var allInserate = [Inserat]()
    var updateCount = 0
    
    let fbhandler = FBHandler()

    var currentinseratannotation : MKAnnotation?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        initview()
    }
    
    func initview() {
        
        manager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            setUp()
            centerMapOnUserLocation()
        } else {
            manager.requestWhenInUseAuthorization()
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            setUp()
        }
    }
    
    func setUp(){
        mapview.delegate = self
        mapview.showsUserLocation = true
        manager.startUpdatingLocation()
        
        loadAllInserate()
        
    }
    
    func centerMapOnUserLocation() {
            guard let coordinate = locationManager.location?.coordinate else {return}
            let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapview.setRegion(coordinateRegion, animated: true)
    }
    
    
    private func updateAnnotations(){
        mapview.removeAnnotations(mapview.annotations)
                
            addAllInserateToMap()
    }
    
    func addAllInserateToMap() {
        
        mapview.removeAnnotations(mapview.annotations)

        for currentinserat in allInserate {
            self.mapview.addAnnotation(currentinserat)
        }
        
    }
    
    func loadAllInserate() {
        fbhandler.loadInserate() { inseratelist in
             guard let inseratelist = inseratelist else { return }
                
            self.allInserate.removeAll()
            self.allInserate = inseratelist
            self.addAllInserateToMap()
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
        mapview.deselectAnnotation(view.annotation, animated: true)
        if view.annotation is MKUserLocation {
            Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { (timer) in
                if let coord = self.manager.location?.coordinate{
                    //Eigener User pressed!
                    
                    
                }
            }
        }
        let region = MKCoordinateRegion(center: view.annotation!.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        
        Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { (timer) in
            if let coord = self.manager.location?.coordinate{
                guard let currentselectedinserat = view.annotation as? Inserat else {
                    return
                }
                //Was passiert mit dem gedrückten User:
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "autodetailsview") as! AutoDetailsView
                //newViewController.modalPresentationStyle = .fullScreen
                newViewController.selectedInserat = currentselectedinserat
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        if annotation is MKUserLocation {
            
            currentinseratannotation = annotation
            
            annoView.image = #imageLiteral(resourceName: "009")
            //annoView.image = (annotation as! User).profileimage!

            var frame = annoView.frame
            frame.size.height = 70
            frame.size.width = 70
            annoView.frame = frame
            /*let url = URL(string: HomeTab.currentUser!.profilepictureurl!)
            KingfisherManager.shared.retrieveImage(with: url as! Resource, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                annoView.image = image
            })*/
            annoView.layer.cornerRadius = annoView.bounds.width/2
            annoView.clipsToBounds = true
            //annoView.layer.borderWidth = 2
            annoView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            return annoView
        } else {
            
            
            annoView.image = #imageLiteral(resourceName: "car")
            
            var frame = annoView.frame
            frame.size.height = 70
            frame.size.width = 70
            annoView.frame = frame
            /*let url = URL(string: (annotation as! User).profilepictureurl!)
            KingfisherManager.shared.retrieveImage(with: url as! Resource, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                annoView.image = image
            })*/
            annoView.layer.cornerRadius = annoView.bounds.width/2
            annoView.clipsToBounds = true
            //annoView.layer.borderWidth = 2
            annoView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            return annoView
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
    }

}


extension MKAnnotationView {
  public func maskCircle(anyImage: UIImage) {
    self.contentMode = UIView.ContentMode.scaleAspectFill
    self.layer.cornerRadius = self.frame.height / 2
    self.layer.masksToBounds = false
    self.clipsToBounds = true

   // make square(* must to make circle),
   // resize(reduce the kilobyte) and
   // fix rotation.
   self.image = anyImage
  }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}


extension UIImage {
  func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        
    guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
    defer { UIGraphicsEndImageContext() }
        
    let rect = CGRect(origin: .zero, size: size)
    ctx.setFillColor(color.cgColor)
    ctx.fill(rect)
    ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
    ctx.draw(image, in: rect)
        
    return UIGraphicsGetImageFromCurrentImageContext() ?? self
  }
}
