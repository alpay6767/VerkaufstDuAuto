//
//  fbhandler.swift
//  VerkaufstDuAuto
//
//  Created by Alpay Kücük on 25.09.21.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage


class FBHandler {
    
    
    init() {
        
    }
    
    
    func uploadMedia(image: UIImage, currentinserat: Inserat, currentBild: Bild, completion: @escaping (_ url: String?) -> Void) {
        
        let storageRef = Storage.storage().reference().child("Inserate").child(currentinserat.id!).child("Bilder").child(currentBild.id! + ".png")
        if let uploadData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("error")
                    completion(nil)
                } else {

                    storageRef.downloadURL(completion: { (url, error) in

                        //print(url?.absoluteString)
                        completion(url?.absoluteString)
                    })

                  //  completion((metadata?.downloadURL()?.absoluteString)!))
                    // your uploaded photo url.


                }
            }
        }
    }
    
    
    func getDataFromUrl(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, imageview: UIImageView) {
        print("Download Started")
        getDataFromUrl(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                imageview.image = UIImage(data: data)
            }
        }
    }
    
    func getBilderForInserat(currentinserat: Inserat, completion: @escaping (_ bilderlist: [Bild]?) -> Void){

        var ref: DatabaseReference!
        ref = Database.database(url: "https://challenges-cfbd3-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
        ref?.child("Inserate").child(currentinserat.id!).child("Bilder").observeSingleEvent(of: .value, with: { snapshot in

            var bilderliste = [Bild]()

            if !snapshot.exists() {
                
                completion(bilderliste)
                
            }
            
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                var counter = result.count
                
                for child in result {

                    var loadedBild = Bild(snapshot: child)
                    bilderliste.append(loadedBild)
                    
                }
                completion(bilderliste)
            }
        })
    }
    
    func loadInserate(completion: @escaping (_ inseratliste: [Inserat]?) -> Void){

        var ref: DatabaseReference!
        ref = Database.database(url: "https://challenges-cfbd3-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
        ref?.child("Inserate").queryLimited(toLast: 30).observeSingleEvent(of: .value, with: { snapshot in

            var inseratlist = [Inserat]()
            
            if !snapshot.exists() {
                completion(inseratlist)
                
            }

            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                var counter = result.count
                
                for child in result {

                    var loadedInserat = Inserat(snapshot: child)

                    self.getBilderForInserat(currentinserat: loadedInserat) { bilderlist  in
                        guard let bilderlist = bilderlist else { return }
                        loadedInserat.bilder = bilderlist
                        inseratlist.append(loadedInserat)
                        completion(inseratlist)
                     }
                }
                
                completion(inseratlist)
            }
        })
    }
    
    
    func loadInserateOnlyGemerkt(completion: @escaping (_ inseratliste: [Inserat]?) -> Void){

        var ref: DatabaseReference!
        ref = Database.database(url: "https://challenges-cfbd3-default-rtdb.europe-west1.firebasedatabase.app").reference()
        
        ref?.child("Inserate").queryLimited(toLast: 30).observeSingleEvent(of: .value, with: { snapshot in

            var inseratlist = [Inserat]()
            
            if !snapshot.exists() {
                completion(inseratlist)
                
            }

            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                var counter = result.count
                
                for child in result {

                    var loadedInserat = Inserat(snapshot: child)

                    self.getBilderForInserat(currentinserat: loadedInserat) { bilderlist  in
                        guard let bilderlist = bilderlist else { return }
                        loadedInserat.bilder = bilderlist
                        if (loadedInserat.gemerkt) {
                        inseratlist.append(loadedInserat)
                        completion(inseratlist)
                        }
                     }
                }
                
                completion(inseratlist)
            }
        })
    }
    
    
}
