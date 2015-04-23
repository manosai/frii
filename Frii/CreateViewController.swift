//
//  CreateViewController.swift
//  Frii
//
//  Created by Manosai Eerabathini on 4/10/15.
//  Copyright (c) 2015 Frii, Inc. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController {

    @IBAction func createButton(sender: AnyObject) {
        var object = PFObject(className:"Schedules")
        
        object["startDate"] = "04/10/15"
        object["endDate"] = "04/12/15"
        object["startTime"] = 9
        object["startAM"] = true
        object["endTime"] = 6
        object["endPM"] = true
        
        // Save the data back to the server in a background task
        object.saveEventually(nil)
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
