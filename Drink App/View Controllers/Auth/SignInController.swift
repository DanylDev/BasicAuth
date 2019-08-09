//
//  SignInController.swift
//  Drink App
//
//  Created by Denis Yakovenko on 2/1/19.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import UIKit
import PasswordTextField
import MBProgressHUD

class SignInController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: PasswordTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var viewBackground: UIImageView!
    
    @IBOutlet var constraintViewVerticalAlign: NSLayoutConstraint!
    @IBOutlet var constraintViewTop: NSLayoutConstraint!

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    var mode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        constraintViewTop.isActive = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        viewBackground.addGestureRecognizer(tap)
        viewBackground.isUserInteractionEnabled = true
        
        emailField.addPadding(.left(10.0))
        emailField.layer.borderColor = field_border_color.cgColor
        emailField.layer.borderWidth = 1.0
        
        passwordField.addPadding(.left(10.0))
        passwordField.layer.borderColor = field_border_color.cgColor
        passwordField.layer.borderWidth = 1.0
        
        loginButton?.layer.borderWidth = 1.0
        loginButton?.layer.borderColor = main_color.cgColor
    }
    
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    @IBAction func tapLogin(_ sender: UIButton) {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Logging in ..."
        
        Networking.sharedInstance.userLogin(email: emailField.text ?? "", password: passwordField.text ?? "") { (success, error) in
            hud.hide(animated: true)
            if(success) {
                if (self.mode == "order") {
                    self.dismiss(animated: true, completion: {
                        let notificationName = Notification.Name("didLogin")
                        NotificationCenter.default.post(name: notificationName, object: nil)
                    })
                }
                else {
                    let locationAccessViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocationAccessViewController")
                    self.navigationController?.viewControllers = [locationAccessViewController]
                }
            } else {
                let alertController = UIAlertController(title: "Problem", message: error, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension SignInController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        constraintViewVerticalAlign.isActive = false
        constraintViewTop.isActive = true
        constraintViewTop.constant = 0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        constraintViewVerticalAlign.isActive = true
        constraintViewTop.isActive = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            tapLogin(UIButton())
        }
        return true
    }
}
