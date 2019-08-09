//
//  AuthTypeController.swift
//  Drink App
//
//  Created by Denis Yakovenko on 2/1/19.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import UIKit

class AuthTypeController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    var mode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil;
        self.signInButton?.layer.borderWidth = 1.0
        self.signInButton?.layer.borderColor = main_color.cgColor
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(false, forKey: "logoutNow")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // if already logged in
        if let _ = UserDefaults.standard.value(forKey: "token") as? String {
            let locationAccessViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocationAccessViewController")
            self.navigationController?.viewControllers = [locationAccessViewController]
        }
    }
    
    @IBAction func tapSkip(_ sender: Any) {
        if (self.mode == "order") {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.performSegue(withIdentifier: "AuthTypeToLocationAccess", sender: self)
        }
    }
    
    @IBAction func tapSignIn(_ sender: Any) {
        self.performSegue(withIdentifier: "AuthTypeToLogin", sender: self)
    }

    @IBAction func tapNewUser(_ sender: Any) {
        self.performSegue(withIdentifier: "AuthTypeToRegister", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AuthTypeToLogin" {
            if let destinationVC = segue.destination as? SignInController {
                destinationVC.mode = self.mode
            }
        }
        else if segue.identifier == "AuthTypeToRegister" {
            if let destinationVC = segue.destination as? SignUpController {
                destinationVC.mode = self.mode
            }
        }
    }

}
