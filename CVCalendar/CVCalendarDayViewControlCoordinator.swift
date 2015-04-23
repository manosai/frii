//
//  CVCalendarDayViewControlCoordinator.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

private let instance = CVCalendarDayViewControlCoordinator()

class CVCalendarDayViewControlCoordinator: NSObject {
    
    var inOrderNumber = 0
    
    class var sharedControlCoordinator: CVCalendarDayViewControlCoordinator {
        return instance
    }
   
    var selectedDayView: CVCalendarDayView? = nil
    var animator: CVCalendarViewAnimatorDelegate?
    
    lazy var appearance: CVCalendarViewAppearance = {
       return CVCalendarViewAppearance.sharedCalendarViewAppearance
    }()
    
    private override init() {
        super.init()
    }
    
    func performDayViewSelection(dayView: CVCalendarDayView) {
        if let selectedDayView = self.selectedDayView {
            if selectedDayView != dayView {
                if self.inOrderNumber < 2 {
                    self.presentDeselectionOnDayView(self.selectedDayView!)
                    self.selectedDayView = dayView
                    self.presentSelectionOnDayView(self.selectedDayView!)
                }
            } else {
                // if we want to unselect what we just selected
                // look for white text
                if (selectedDayView.dayLabel?.textColor == .whiteColor()) {
                    println("already selected")
                    var color: UIColor? = appearance.dayLabelWeekdayInTextColor
                    if selectedDayView.isCurrentDay {
                        color = appearance.dayLabelPresentWeekdayTextColor
                    }
                    var font: UIFont? = UIFont.systemFontOfSize(appearance.dayLabelWeekdayTextSize!)
                    
                    selectedDayView.dayLabel?.textColor = color
                    selectedDayView.dayLabel?.font = font
                    
                    selectedDayView.circleView?.removeFromSuperview()
                    selectedDayView.circleView = nil
                    
                    // delete it from the array as well
                    // go through the array and add everything back except for the date
                    // that was just deleted
                    var dates = [String]()
                    let dateFormatter1 = NSDateFormatter()
                    dateFormatter1.dateFormat = "MMMM"
                    let dateFormatter2 = NSDateFormatter()
                    dateFormatter2.dateFormat = "YYYY"
                    var month = dateFormatter1.stringFromDate(selectedDayView.weekView!.monthView!.date!)
                    var year = dateFormatter2.stringFromDate(selectedDayView.weekView!.monthView!.date!)
                    var day = String(selectedDayView.dayLabel?.text ?? "")
                    var myDate = year+"-"+month+"-"+day
                    
                    var dayOfWeek = "Sample"
                    let formatter  = NSDateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    if let todayDate = formatter.dateFromString(myDate) {
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "EEEE"
                        let dayOfWeekString = dateFormatter.stringFromDate(todayDate)
                        
                        dayOfWeek = dayOfWeekString
                    }
                    
                    if var currentDates =
                        NSUserDefaults.standardUserDefaults().arrayForKey("scheduleDates")? {
                            var deletedDate = month+" "+day+" "+dayOfWeek
                            for elem in currentDates {
                                if elem as NSString != deletedDate {
                                    dates.append(String(elem as NSString))
                                }
                            }
                            
                            NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "scheduleDates")
                            NSUserDefaults.standardUserDefaults().synchronize()
                    }

                }
                else {
                    let dateFormatter1 = NSDateFormatter()
                    dateFormatter1.dateFormat = "MMMM"
                    let dateFormatter2 = NSDateFormatter()
                    dateFormatter2.dateFormat = "YYYY"
                    var month = dateFormatter1.stringFromDate(selectedDayView.weekView!.monthView!.date!)
                    var year = dateFormatter2.stringFromDate(selectedDayView.weekView!.monthView!.date!)
                    var day = String(selectedDayView.dayLabel?.text ?? "")
                    var myDate = year+"-"+month+"-"+day
                    
                    var dayOfWeek = "Sample"
                    let formatter  = NSDateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    if let todayDate = formatter.dateFromString(myDate) {
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "EEEE"
                        let dayOfWeekString = dateFormatter.stringFromDate(todayDate)
                        
                        dayOfWeek = dayOfWeekString
                    }
                    
                    
                    
                    // add to array
                    //dates.append(self.dayLabel)
                    if var currentDates =
                        NSUserDefaults.standardUserDefaults().arrayForKey("scheduleDates")? {
                            currentDates.append(month+" "+day+" "+dayOfWeek)
                            println(currentDates)
                            NSUserDefaults.standardUserDefaults().setObject(currentDates, forKey: "scheduleDates")
                            NSUserDefaults.standardUserDefaults().synchronize()
                    }
                    else {
                        var dates = [String]()
                        dates.append(String(selectedDayView.dayLabel?.text ?? ""))
                        NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "scheduleDates")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                    }

                    var color: UIColor? = appearance.dayLabelWeekdayHighlightedBackgroundColor
                    var _alpha = appearance.dayLabelWeekdayHighlightedBackgroundAlpha
                    selectedDayView.dayLabel?.textColor = appearance.dayLabelWeekdayHighlightedTextColor
                    selectedDayView.dayLabel?.font = UIFont.boldSystemFontOfSize(appearance.dayLabelWeekdayHighlightedTextSize!)
                    selectedDayView.circleView = CVCircleView(frame: CGRectMake(0, 0, selectedDayView.dayLabel!.frame.width, selectedDayView.dayLabel!.frame.height), color: color!, _alpha: _alpha!)
                    selectedDayView.insertSubview(selectedDayView.circleView!, atIndex: 0)
                    
                }
            }
        } else {
            self.selectedDayView = dayView
            if self.animator == nil {
                self.animator = self.selectedDayView!.weekView!.monthView!.calendarView!.animator
            }
            self.presentSelectionOnDayView(self.selectedDayView!)
        }
    }
    
    private func presentSelectionOnDayView(dayView: CVCalendarDayView) {
        self.animator?.animateSelection(dayView, withControlCoordinator: CVCalendarDayViewControlCoordinator.sharedControlCoordinator)
    }
    
    private func presentDeselectionOnDayView(dayView: CVCalendarDayView) {
//        self.animator?.animateDeselection(dayView, withControlCoordinator: CVCalendarDayViewControlCoordinator.sharedControlCoordinator)
    }
    
    func animationStarted() {
        self.inOrderNumber++
    }
    
    func animationEnded() {
        self.inOrderNumber--
    }
}
