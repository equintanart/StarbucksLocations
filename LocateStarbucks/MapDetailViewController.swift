//
//  MapDetailViewController.swift
//  LocateStarbucks
//
//  Created by Erick Quintanar on 4/30/17.
//  Copyright © 2017 equintanart. All rights reserved.
//

import UIKit
import GoogleMaps

class MapDetailViewController: UIViewController {

    var latitud  = Double()
    var longitud = Double()
    var vicinity = String()
    
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: latitud, longitude: longitud, zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
        marker.title = "Starbucks"
        marker.snippet = vicinity
        marker.icon = UIImage(named: "marker")
        marker.map = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
