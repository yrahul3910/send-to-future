//
//  NotificationManager.swift
//  SendToFuture
//
//  Created by Rahul Yedida on 4/9/21.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject {
    override init() {
        super.init()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted == true && error == nil {
                print("Notifications permitted")
                UNUserNotificationCenter.current().delegate = self
            } else {
                print("Notifications not permitted")
            }
        }
    }
    
    func scheduleNotification(url: String, title: String, time: Int = 3600) {
        // Define the custom actions.
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                title: "Open",
                                                options: UNNotificationActionOptions(rawValue: 0))
        let deferAction = UNNotificationAction(identifier: "DEFER_1HOUR_ACTION",
                                               title: "Remind me in 1 hour",
                                               options: UNNotificationActionOptions(rawValue: 0))
        
        // Define the notification type
        let notifCategory =
            UNNotificationCategory(identifier: "FUTURE_NOTIFICATION",
                                   actions: [acceptAction, deferAction],
                                   intentIdentifiers: [],
                                   hiddenPreviewsBodyPlaceholder: "",
                                   options: .customDismissAction)
        
        // And now schedule the notification
        let content = UNMutableNotificationContent()
        content.title = "The future is now!"
        content.body = "Tap to open the link you sent to future you."
        content.userInfo = ["TITLE": title,
                            "URL": url]
        content.categoryIdentifier = "FUTURE_NOTIFICATION"
        
        // Create notification trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval.init(time), repeats: false)
        
        // Create notification request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([notifCategory])
        notificationCenter.add(request) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Notification sent successfully")
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Get the meeting ID from the original notification.
        let userInfo = response.notification.request.content.userInfo
        
        if response.notification.request.content.categoryIdentifier ==
            "FUTURE_NOTIFICATION" {
            // Retrieve the details.
            let pageURL = userInfo["URL"] as! String
            let title = userInfo["TITLE"] as! String
            
            switch response.actionIdentifier {
            case "ACCEPT_ACTION", UNNotificationDefaultActionIdentifier:
                guard let url = URL(string: pageURL) else {
                    print(pageURL + " failed to open")
                    return
                }
                UIApplication.shared.open(url)
                break
                
            case "DEFER_1HOUR_ACTION":
                self.scheduleNotification(url: pageURL, title: title)
                break
                
            case UNNotificationDismissActionIdentifier:
                // Queue meeting-related notifications for later
                //  if the user does not act.
                break
                
            default:
                break
            }
        }
        
        // Always call the completion handler when done.
        completionHandler()
    }
}
