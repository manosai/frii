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

                }
                else {
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
