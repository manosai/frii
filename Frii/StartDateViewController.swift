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
    @IBOutlet weak var monthLabel: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        if var currentDates = NSUserDefaults.standardUserDefaults().arrayForKey("scheduleDates")? {
            NSUserDefaults.standardUserDefaults().setObject([], forKey: "scheduleDates")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        self.monthLabel.text = CVDate(date: NSDate()).description()
        super.viewDidAppear(animated)
        
        self.calendarView.commitCalendarViewUpdate()
        self.menuView.commitMenuViewUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        let cSelector : Selector = "reset:"
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: cSelector)
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.monthLabel.text = CVDate(date: NSDate()).description()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentedDateUpdated(date: CVDate) {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
