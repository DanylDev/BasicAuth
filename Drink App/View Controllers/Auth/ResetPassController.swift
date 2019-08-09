//
//  ResetPassController.swift
//  Drink App
//
//  Created by Denis Yakovenko on 2/1/19.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class ResetPassController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var resetPassBtn: UIButton!
    
    @IBOutlet weak var viewBackground: UIImageView!
    
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.addPadding(.left(10.0))
        emailField.layer.borderColor = field_border_color.cgColor
        emailField.layer.borderWidth = 1.0
        
        resetPassBtn?.layer.borderWidth = 1.0
        resetPassBtn?.layer.borderColor = main_color.cgColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        viewBackground.addGestureRecognizer(tap)
        viewBackground.isUserInteractionEnabled = true
    }
    
    @IBAction func tapReset(_ sender: Any) {

        if (emailField.text == "") {
            let alertController = UIAlertController(title: "Problem", message: "Please enter your email address.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Resetting ..."

        Networking.sharedInstance.userResetPassword(email: emailField.text ?? "") { (success, error) in
            hud.hide(animated: true)
            let resetPassSuccessViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResetPassSuccessViewController") as! ResetPassSuccessViewController
            self.navigationController?.pushViewController(resetPassSuccessViewController, animated: true)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        emailField.resignFirstResponder()
    }
    
    @IBAction func tapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ResetPassController:UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        constraintTop.constant = -175
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        constraintTop.constant = 57
    }
}
