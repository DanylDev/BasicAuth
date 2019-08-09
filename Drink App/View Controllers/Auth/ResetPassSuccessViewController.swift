//
//  ResetPassSuccessViewController.swift
//  Drink App
//
//  Created by Andrew Dunn on 13/02/2019.
//  Copyright © 2019 Denis Yakovenko. All rights reserved.
//

import UIKit

class ResetPassSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapBack(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
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
