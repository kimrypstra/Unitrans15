//
//  UTSafariViewController.swift
//  Unitrans
//
//  Created by Kim Rypstra on 29/11/16.
//  Copyright © 2016 Kim Rypstra. All rights reserved.
//

import UIKit
import SafariServices

class UTSafariViewController: SFSafariViewController {

    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.frame.origin.y = 85
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
