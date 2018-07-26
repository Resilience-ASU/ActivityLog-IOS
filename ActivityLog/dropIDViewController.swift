//
//  dropIDViewController.swift
//  ActivityLog
//
//  Created by Ziqi Li on 7/24/18.
//  Copyright © 2018 Ziqi Li. All rights reserved.
//

import UIKit
import Eureka
import Parse

class dropIDViewController: FormViewController {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()

        form +++
        Section("Plase Enter Your Kestrel Drop ID")
            <<< TextRow("id"){ row in      // initializer
                row.value = UserDefaults.standard.string(forKey: "dropid")
            }
    }
    override func viewWillDisappear(_ animated: Bool) {
        let row: TextRow? = form.rowBy(tag: "id")
        if row?.value != UserDefaults.standard.string(forKey: "dropid"){
            print("Changed Device")
            if delegate.connectedDrop != nil {
                delegate.centralManager.cancelPeripheralConnection(delegate.connectedDrop)
            }
            if (PFUser.current()?.username != nil) {
                PFUser.current()?["dropid"] = row?.value
                PFUser.current()?.saveEventually()
            }
        }
        if row?.value == nil{
            print("Cleared")
            UserDefaults.standard.set("No ID Yet", forKey: "dropid")
        }
        else{
            UserDefaults.standard.set(row?.value, forKey: "dropid")
        }
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
