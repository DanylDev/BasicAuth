//
//  LocationAccessViewController.swift
//  Drink App
//
//  Created by Andrew Dunn on 14/02/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import UIKit
import CoreLocation
import MBProgressHUD

class LocationAccessViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var hud:MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
//        hud.hide(animated: true)
        
        if status == .denied {
            // disabled
            self.performSegue(withIdentifier: "showLocation", sender: nil)
            
//            let locationsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocationsViewController") as! LocationsViewController
//            let authTypeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthTypeController") as! AuthTypeController
//            self.navigationController?.viewControllers = [authTypeController, locationsViewController]
        }
        else if status == .authorizedWhenInUse {
            // enabled
            self.performSegue(withIdentifier: "showLocation", sender: nil)
//            let locationsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocationsViewController") as! LocationsViewController
//            let authTypeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthTypeController") as! AuthTypeController
//            self.navigationController?.viewControllers = [authTypeController, locationsViewController]
        }
    }
}
