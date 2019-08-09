//
//  SignUpSuccessViewController.swift
//  Drink App
//
//  Created by Andrew Dunn on 05/03/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import UIKit

class SignUpSuccessViewController: UIViewController {

    var mode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapSkip(_ sender: Any) {
        if (self.mode == "order") {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            let locationAccessViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LocationAccessViewController")
            self.navigationController?.viewControllers = [locationAccessViewController]
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
