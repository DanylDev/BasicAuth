//
//  SignUpController.swift
//  Drink App
//
//  Created by Denis Yakovenko on 2/1/19.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import UIKit
import PasswordTextField
import MBProgressHUD

class SignUpController : UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: PasswordTextField!
    @IBOutlet weak var registerButton: UIButton!
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
        
        nameField.addPadding(.left(10.0))
        nameField.layer.borderColor = field_border_color.cgColor
        nameField.layer.borderWidth = 1.0
        
        emailField.addPadding(.left(10.0))
        emailField.layer.borderColor = field_border_color.cgColor
        emailField.layer.borderWidth = 1.0
        
        passwordField.addPadding(.left(10.0))
        passwordField.layer.borderColor = field_border_color.cgColor
        passwordField.layer.borderWidth = 1.0

        registerButton?.layer.borderWidth = 1.0
        registerButton?.layer.borderColor = main_color.cgColor
    }
    
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapRegister(_ sender: UIButton) {
        
        // validate
        var errors:[String] = []
        if (nameField.text?.replacingOccurrences(of: " ", with: "") == "") {
            errors.append("Enter your name.")
        }
        if (emailField.text?.replacingOccurrences(of: " ", with: "") == "") {
            errors.append("Enter an email address.")
        }
        if (!(emailField.text?.replacingOccurrences(of: " ", with: "").isValidEmail())!) {
            errors.append("Enter a valid email address.")
        }
        if (passwordField.text?.replacingOccurrences(of: " ", with: "") == "") {
            errors.append("Enter a password.")
        }

        if (errors.count > 0) {
            var message = "Please review the information you entered.\n\n"
            for error in errors {
                message = message + "- " + error + "\n"
            }
            let alertController = UIAlertController(title: "Problem", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Registering ..."
        
        Networking.sharedInstance.userRegister(name: nameField.text ?? "", email: emailField.text ?? "", password: passwordField.text ?? "") { (success, error) in
            hud.hide(animated: true)
            if (success) {
                let signUpSuccessViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpSuccessViewController") as! SignUpSuccessViewController
                signUpSuccessViewController.mode = self.mode
                self.navigationController?.pushViewController(signUpSuccessViewController, animated: true)
            } else {
                let alertController = UIAlertController(title: "Problem", message: error, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        nameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
}

extension SignUpController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == nameField) {
            emailField.becomeFirstResponder()
        }
        else if (textField == emailField) {
            passwordField.becomeFirstResponder()
        }
        else {
            tapRegister(UIButton())
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        constraintViewVerticalAlign.isActive = false
        constraintViewTop.isActive = true
        constraintViewTop.constant = 0
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        constraintViewVerticalAlign.isActive = true
        constraintViewTop.isActive = false
    }

}
