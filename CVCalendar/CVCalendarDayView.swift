//
//  CVCalendarDayView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarDayView: UIView {
    
    // MARK: - Public properties

    var weekView: CVCalendarWeekView?
    let weekdayIndex: Int?
    let date: CVDate?
    
    var dayLabel: UILabel?
    var circleView: CVCircleView?
    var topMarker: CALayer?
    var dotMarker: CVCircleView?
    
    var isOut = false
    var isCurrentDay = false
    
    var counter = 0
    var dates = [String]()
    
    // MARK: - Initialization
    
    init(weekView: CVCalendarWeekView, frame: CGRect, weekdayIndex: Int) {
        super.init()
        self.weekView = weekView
        self.frame = frame
        self.weekdayIndex = weekdayIndex
        
        func hasDayAtWeekdayIndex(weekdayIndex: Int, weekdaysDictionary: [Int : [Int]]) -> Bool {
            let keys = weekdaysDictionary.keys
            
            for key in keys.array {
                //println("Key: \(key), weekday index:\(weekdayIndex)")
                if key == weekdayIndex {
                    return true
                }
            }
            
            return false
        }
        
        
        var day: Int?
        
        let weekdaysIn = self.weekView!.weekdaysIn!
        if let weekdaysOut = self.weekView?.weekdaysOut {
            if hasDayAtWeekdayIndex(self.weekdayIndex!, weekdaysOut) {
                self.isOut = true
                day = weekdaysOut[self.weekdayIndex!]![0]
            } else if hasDayAtWeekdayIndex(self.weekdayIndex!, weekdaysIn) {
                day = weekdaysIn[self.weekdayIndex!]![0]
            }
        } else {
            day = weekdaysIn[self.weekdayIndex!]![0]
        }
        
        if day == self.weekView!.monthView!.currentDay && !self.isOut {
            let manager = CVCalendarManager.sharedManager
            let dateRange = manager.dateRange(self.weekView!.monthView!.date!)
            let currentDateRange = manager.dateRange(NSDate())
            
            if dateRange.month == currentDateRange.month && dateRange.year == currentDateRange.year {
                self.isCurrentDay = true
            }
            
        }
        

        
        var shouldShowDaysOut = self.weekView!.monthView!.calendarView!.shouldShowWeekdaysOut!
        
        let calendarManager = CVCalendarManager.sharedManager
        let year = calendarManager.dateRange(self.weekView!.monthView!.date!).year
        var month: Int? = calendarManager.dateRange(self.weekView!.monthView!.date!).month
        if self.isOut {
            if day > 20 {
                month! -= 1
            } else {
                month! += 1
            }
            
            if !shouldShowDaysOut {
                self.hidden = true
            }
        }
        
        self.date = CVDate(day: day!, month: month!, week: self.weekView!.index!, year: year)
        
        self.labelSetup()
        self.topMarkerSetup()
        self.setupGestures()
        self.setupDotMarker()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties setup
    
    func labelSetup() {
        let appearance = CVCalendarViewAppearance.sharedCalendarViewAppearance
        
        self.dayLabel = UILabel()
        self.dayLabel!.text = String(self.date!.day!)
        self.dayLabel!.textAlignment = NSTextAlignment.Center
        self.dayLabel!.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        
        var font: UIFont? = UIFont.systemFontOfSize(appearance.dayLabelWeekdayTextSize!)
        var color: UIColor?
        if self.isOut {
            color = appearance.dayLabelWeekdayOutTextColor
        } else if self.isCurrentDay {
            let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
            if coordinator.selectedDayView == nil {
                self.weekView!.monthView!.receiveDayViewTouch(self)
            } else {
                color = appearance.dayLabelPresentWeekdayTextColor
                font = UIFont.boldSystemFontOfSize(appearance.dayLabelPresentWeekdayTextSize!)
            }
            
        } else {
            color = appearance.dayLabelWeekdayInTextColor
        }
        
        
        if color != nil && font != nil {
            self.dayLabel!.textColor = color!
            self.dayLabel!.font = font
        }
        
        self.addSubview(self.dayLabel!)
    }
    
    
    func topMarkerSetup() {
        func createMarker() {
            let height = CGFloat(0.5)
            let layer = CALayer()
            layer.borderColor = UIColor.grayColor().CGColor
            layer.borderWidth = height
            layer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), height)
            
            self.topMarker = layer
            
            self.layer.addSublayer(self.topMarker!)
        }
        
        if let delegate = self.weekView!.monthView!.calendarView!.delegate {
            if delegate.topMarker(shouldDisplayOnDayView: self) {
                if self.topMarker != nil {
                    self.topMarker?.removeFromSuperlayer()
                    self.topMarker = nil
                }
                
                createMarker()
            } else {
                if self.topMarker != nil {
                    self.topMarker?.removeFromSuperlayer()
                    self.topMarker = nil
                }
            }
        } else {
            if self.topMarker == nil {
                createMarker()
            } else {
                self.topMarker?.removeFromSuperlayer()
                self.topMarker = nil
                createMarker()
            }
        }
    }
    
    func setupDotMarker() {
        if let delegate = self.weekView!.monthView!.calendarView!.delegate {
            if delegate.dotMarker(shouldShowOnDayView: self) {
                var color = delegate.dotMarker(colorOnDayView: self)
                let width: CGFloat = 13
                let height = width
                
                let x = self.frame.width / 2
                var yOffset: CGFloat? = 5
                if let appearance = self.weekView!.monthView!.calendarView!.appearanceDelegate {
                    yOffset = appearance.dotMarkerOffset
                }
                let y = CGRectGetMaxY(self.frame) - self.frame.height / yOffset!
                
                let frame = CGRectMake(0, 0, width, height)
                
                if self.isOut {
                    color = UIColor.grayColor()
                }
                
                self.dotMarker = CVCircleView(frame: frame, color: color, _alpha: 1)
                self.dotMarker?.center = CGPointMake(x, y)
                
                self.insertSubview(self.dotMarker!, atIndex: 0)
                
                let coordinator = CVCalendarDayViewControlCoordinator.sharedControlCoordinator
                if self == coordinator.selectedDayView {
                    self.moveDotMarker(false)
                }
            }
        }
    }
    
    // MARK: - Events handling
    
    func setupGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "dayViewTapped")
        self.addGestureRecognizer(tapRecognizer)
    }
    
    func dayViewTapped() {
        let monthView = self.weekView!.monthView!
        monthView.receiveDayViewTouch(self)
    }
    
    // MARK: - Label states management
    
    func moveDotMarker(unwinded: Bool) {
        if self.dotMarker != nil {
            var shouldMove = true
            if let delegate = self.weekView!.monthView!.calendarView!.delegate {
                shouldMove = delegate.dotMarker(shouldMoveOnHighlightingOnDayView: self)
            }
            if !unwinded && shouldMove {
                let radius = (self.circleView!.frame.size.width - 10)/2
                let center = CGPointMake((self.circleView!.frame.size.width)/2, self.circleView!.frame.size.height/2)
                let maxArcPointY = center.y + radius
                self.diff = maxArcPointY - self.dotMarker!.frame.origin.y/0.95
                
                if self.diff > 0 {
                    self.diff = abs(self.diff!)
                    
                    UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                        self.dotMarker!.frame.origin.y += self.diff!
                        }, completion: nil)
                } else {
                    self.diff = nil
                }
            } else if self.diff != nil && shouldMove {
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.dotMarker!.frame.origin.y -= self.diff!
                    }, completion: nil)
            } else {
                
                if let dotMarker = self.dotMarker {
                    if let delegate = self.weekView!.monthView!.calendarView!.delegate {
                        let frame = dotMarker.frame
                        var color: UIColor?
                        if unwinded {
                            let appearance = weekView!.monthView!.calendarView!.appearanceDelegate! // Note: if nil then look at recovery mechanism
                            color = (isOut) ? appearance.dayLabelWeekdayOutTextColor : delegate.dotMarker(colorOnDayView: self)
                        } else {
                            if let appearance = self.weekView!.monthView!.calendarView!.appearanceDelegate  {
                                color = appearance.dotMarkerColor!
                            }
                        }
                        
                        let auxiliaryCircleView = CVCircleView(frame: frame, color: color!, _alpha: dotMarker.alpha)
                        self.dotMarker?.removeFromSuperview()
                        self.dotMarker = auxiliaryCircleView
                        self.addSubview(self.dotMarker!)
                    }
                }
            }
        }
    }
    
    private var diff: CGFloat?
    func setDayLabelHighlighted() {
        let appearance = CVCalendarViewAppearance.sharedCalendarViewAppearance
        
        var color: UIColor?
        var _alpha: CGFloat?
        
        // the first time the calendar loads
        if self.isCurrentDay && counter == 0 {
            // do nothing with it
            self.dayLabel?.textColor = .redColor()
            counter += 1
            
        // every other day being selected
        } else {
            counter += 1
            // if the day is already selected and being clicked on, 
            // then unselect it
            if self.dayLabel?.textColor == .whiteColor() {
                println("already selected")
                var color: UIColor? = appearance.dayLabelWeekdayInTextColor
                if self.isCurrentDay {
                    color = appearance.dayLabelPresentWeekdayTextColor
                }
                var font: UIFont? = UIFont.systemFontOfSize(appearance.dayLabelWeekdayTextSize!)
                
                self.dayLabel?.textColor = color
                self.dayLabel?.font = font
                
                self.circleView?.removeFromSuperview()
                self.circleView = nil
                
                // delete it from the array as well
                // go through the array and add everything back except for the date
                // that was just deleted
                var dates = [String]()
                let dateFormatter1 = NSDateFormatter()
                dateFormatter1.dateFormat = "MMMM"
                let dateFormatter2 = NSDateFormatter()
                dateFormatter2.dateFormat = "YYYY"
                var month = dateFormatter1.stringFromDate(self.weekView!.monthView!.date!)
                var year = dateFormatter2.stringFromDate(self.weekView!.monthView!.date!)
                var day = String(self.dayLabel?.text ?? "")
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
                var month = dateFormatter1.stringFromDate(self.weekView!.monthView!.date!)
                var year = dateFormatter2.stringFromDate(self.weekView!.monthView!.date!)
                var day = String(self.dayLabel?.text ?? "")
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
                    dates.append(String(self.dayLabel?.text ?? ""))
                    NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "scheduleDates")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                }
                color = appearance.dayLabelWeekdayHighlightedBackgroundColor
                _alpha = appearance.dayLabelWeekdayHighlightedBackgroundAlpha
                self.dayLabel?.textColor = appearance.dayLabelWeekdayHighlightedTextColor
                self.dayLabel?.font = UIFont.boldSystemFontOfSize(appearance.dayLabelWeekdayHighlightedTextSize!)
                self.circleView = CVCircleView(frame: CGRectMake(0, 0, self.dayLabel!.frame.width, self.dayLabel!.frame.height), color: color!, _alpha: _alpha!)
                self.insertSubview(self.circleView!, atIndex: 0)
               
            }
        }
    }

    func setDayLabelUnhighlighted() {
        let appearance = CVCalendarViewAppearance.sharedCalendarViewAppearance
        var _alpha: CGFloat? = 0.6
        
        var color: UIColor?
        if self.isOut {
            color = appearance.dayLabelWeekdayOutTextColor
        } else if self.isCurrentDay {
            color = appearance.dayLabelPresentWeekdayTextColor
        } else {
            color = .whiteColor()
        }
        
        self.dayLabel?.textColor = color
        
        color = .redColor()
        
        self.circleView = CVCircleView(frame: CGRectMake(0, 0, self.dayLabel!.frame.width, self.dayLabel!.frame.height), color: color!, _alpha: _alpha!)
        self.insertSubview(self.circleView!, atIndex: 0)
    }
    
    // MARK: - View Destruction
    
    func destroy() {
        self.weekView = nil
        self.dayLabel?.removeFromSuperview()
        self.circleView?.removeFromSuperview()
        self.topMarker?.removeAllAnimations()
        self.dotMarker?.removeFromSuperview()
    }
    
    // MARK: - Content reload
    
    func reloadContent() {
        self.dotMarker?.removeFromSuperview()
        self.dotMarker = nil
        self.setupDotMarker()
        var shouldShowDaysOut = self.weekView!.monthView!.calendarView!.shouldShowWeekdaysOut!
        if !shouldShowDaysOut {
            if self.isOut {
                self.hidden = true
            }
        } else {
            if self.isOut {
                self.hidden = false
            }
        }
        
        self.dayLabel?.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        
        self.topMarker?.frame.size.width = self.frame.width
        
        if self.circleView != nil {
            self.setDayLabelUnhighlighted()
            self.setDayLabelHighlighted()
        }
        
    }
    
}