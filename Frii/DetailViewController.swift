//
//  DetailViewController.swift
//  Frii
//
//  Created by Manosai Eerabathini on 4/1/15.
//  Copyright (c) 2015 Frii, Inc. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // Container to store the view table selected object
    var currentObject : PFObject?
    
    // Some text fields
    @IBOutlet weak var nameEnglish: UITextField!
    @IBOutlet weak var nameLocal: UITextField!
    @IBOutlet weak var capital: UITextField!
    @IBOutlet weak var currencyCode: UITextField!
    // The save button
    @IBAction func saveButton(sender: AnyObject) {
        
        // Unwrap the current object object
        if let object = currentObject? {
            
            object["nameEnglish"] = nameEnglish.text
            object["nameLocal"] = nameLocal.text
            object["capital"] = capital.text
            object["currencyCode"] = currencyCode.text
            
            // Save the data back to the server in a background task
            object.saveEventually(nil)
            
        }
        
        // Return to table view
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Unwrap the current object object
        if let object = currentObject? {
            nameEnglish.text = object["nameEnglish"] as String
            nameLocal.text = object["nameLocal"] as String
            capital.text = object["capital"] as String
            currencyCode.text = object["currencyCode"] as String
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}