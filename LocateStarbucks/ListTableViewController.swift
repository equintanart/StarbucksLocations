//
//  ListTableViewController.swift
//  LocateStarbucks
//
//  Created by Erick Quintanar on 4/29/17.
//  Copyright © 2017 equintanart. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import Darwin

class ListTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var placesClient: GMSPlacesClient!
    
    var myLocationLatitud  : Double!
    var myLocationLongitud : Double!
    
    // Google API Key
    let myAPIKey = "AIzaSyDNr4mA00SNvEju5yVOEWXolze9vA0Gjes"
    let pi = Double.pi
    
    // Core Date Instance
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var details : [Details] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMyCurrentLocation()
        getCurrentPlace()
    }

    // Initialiation location libraries
    func getMyCurrentLocation() {
        placesClient = GMSPlacesClient.shared()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Get Current Place will get the exact coordinates for where the phone is located
    func getCurrentPlace() {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if place != nil {
                    self.myLocationLatitud  = place?.coordinate.latitude
                    self.myLocationLongitud = place?.coordinate.longitude
                    DispatchQueue.main.async(execute: {
                        self.getPlacesListed()
                    })
                }
            }
            
        })
    }
    
    func getPlacesListed() {
        // Get the list of places based on My Location (latitud & Longitud)
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(myLocationLatitud!),\(myLocationLongitud!)&radius=30000&keyword=starbuks&key=\(myAPIKey)"
        let url = NSURL(string: urlString)
        let task = URLSession.shared.dataTask(with: url! as URL) {(data, responce, innerError) in
            if let urlContent = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: urlContent, options: []) as! [String : AnyObject]
                    if let results = json["results"] as? [[String : AnyObject]] {
                        DispatchQueue.main.async {
                            for result in results {
                                var lat = 0.0
                                var lng = 0.0
                                var vic = ""
                                var rat = 0.0
                                if let location = result["geometry"]?["location"] as? [String : AnyObject] {
                                    lat = location["lat"] as! Double
                                    lng = location["lng"] as! Double
                                }
                                if let rating  = result["rating"] as? Double {
                                    rat = rating
                                }
                                if let vicinity = result["vicinity"] as? String {
                                    vic = vicinity
                                }
                                let details = Details(context: self.context)
                                details.address  = vic
                                details.latitud  = lat
                                details.longitud = lng
                                details.rating   = rat
                                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                            }
                            DispatchQueue.main.async(execute: {
                                self.getData()
                                self.tableView.reloadData()
                            })
                        }
                    }
                } catch let error {
                    print("error :", error)
                }
            }
        }
        task.resume()
    }
    
    func getData() {
        do {
            details = try context.fetch(Details.fetchRequest())
        } catch let error {
            print("Fetch Failed, error :", error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ListTableViewCell
        
        let detail = details[indexPath.row]
        
        // Cell Info using Core Data
        cell.ratingData.text = detail.rating.description
        
        // Rating Stars
        var imageName = ""
        let rating = detail.rating
        if rating < 1.5 { imageName = "1"   } else
        if rating < 2   { imageName = "1_5" } else
        if rating < 2.5 { imageName = "2"   } else
        if rating < 3   { imageName = "2_5" } else
        if rating < 3.5 { imageName = "3"   } else
        if rating < 4   { imageName = "3_5" } else
        if rating < 4.5 { imageName = "4"   } else
        if rating < 5   { imageName = "4_5" }
        
        cell.ratingStars.image = UIImage(named: imageName)
        cell.vicinityData.text = detail.address
        
        // Calculating Distance
        let lat1 = myLocationLatitud
        let lat2 = detail.latitud
        let dLat = lat2 - lat1!
        
        let lon1 = myLocationLongitud
        let lon2 = detail.longitud
        let dLon = lon2 - lon1!
        
        let dLat2 = dLat * pi / 180
        let dLon2 = dLon * pi / 180
        
        let a = sin(dLat2/2)*sin(dLat2/2) + sin(dLon2/2)*sin(dLon2/2) * cos(lat1! * pi / 180) * cos(lat2 * pi / 180)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let d = 6371 * c
        let dMiles = d/1.6
        
        let distaceTxt = String(format: "%.2f Miles", dMiles)
        cell.openNowData.text = distaceTxt
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "MapDetailViewController") as! MapDetailViewController
        let detail = details[indexPath.row]
        viewController.latitud  = detail.latitud
        viewController.longitud = detail.longitud
        viewController.vicinity = detail.address!
        navigationController?.pushViewController(viewController, animated: true)
    }
}
