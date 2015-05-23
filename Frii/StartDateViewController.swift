//
//  StartDateViewController.swift
//  Frii
//
//  Created by Manosai Eerabathini on 4/10/15.
//  Copyright (c) 2015 Frii, Inc. All rights reserved.
//

import UIKit

class StartDateViewController: UIViewController {
    
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!

    @IBOutlet weak var startAMPM: UISegmentedControl!
    @IBOutlet weak var endAMPM: UISegmentedControl!
    
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var startSlider: UISlider!
    
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var endSlider: UISlider!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    var shouldShowDaysOut = true
    
    override func viewDidAppear(animated: Bool) {
        if var currentDates = NSUserDefaults.standardUserDefaults().arrayForKey("scheduleDates")? {
            NSUserDefaults.standardUserDefaults().setObject([], forKey: "scheduleDates")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        super.viewDidAppear(animated)
        self.calendarView.commitCalendarViewUpdate()
        self.menuView.commitMenuViewUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        self.monthLabel.text = CVDate(date: NSDate()).description()
        endAMPM.selectedSegmentIndex = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startSliderChanged(sender: UISlider) {
        startTime.text = String(format: "%.0f", startSlider.value)+":00"
    }
    
    @IBAction func endSliderChanged(sender: UISlider) {
        endTime.text = String(format: "%.0f", endSlider.value)+":00"
    }
    
    @IBAction func initializeSchedule(sender: UIBarButtonItem) {
        var object = PFObject(className: "Schedules")
        if var currentDates = NSUserDefaults.standardUserDefaults().arrayForKey("scheduleDates")? {
            
            // create the object attributes to be added to the DB
            object["dates"] = currentDates
            object["startTime"] = startTime.text
            object["endTime"] = endTime.text
            if startAMPM.selectedSegmentIndex == 0 {
                object["startAM"] = true
            }
            else {
                object["startAM"] = false
            }
            if endAMPM.selectedSegmentIndex == 0 {
                object["endPM"] = false
            }
            else {
                object["endPM"] = true
            }
            
            // Save the data back to the server in a background task
            object.saveEventually(nil)
            
        }
        
        
        
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

extension StartDateViewController: CVCalendarViewDelegate {
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func didSelectDayView(dayView: CVCalendarDayView) {
        println("mike check")
    }
    
    func presentedDateUpdated(date: CVDate) {
        println("we get here")
        if self.monthLabel.text != date.description()  {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.description
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
                self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransformIdentity
                
                }) { (finished) -> Void in
                    self.monthLabel.frame = updatedMonthLabel.frame
                    self.monthLabel.text = updatedMonthLabel.text
                    self.monthLabel.transform = CGAffineTransformIdentity
                    self.monthLabel.alpha = 1
                    updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        let day = dayView.date
        let randomDay = Int(arc4random_uniform(31))
        if day == randomDay {
            return true
        }
        
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> UIColor {
        let day = dayView.date
        
        let red = CGFloat(arc4random_uniform(600) / 255)
        let green = CGFloat(arc4random_uniform(600) / 255)
        let blue = CGFloat(arc4random_uniform(600) / 255)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        
        return color
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
}
    

