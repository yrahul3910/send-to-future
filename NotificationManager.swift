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
            
            switch response.actionIdentifier {
            case "ACCEPT_ACTION", UNNotificationDefaultActionIdentifier:
                guard let url = URL(string: pageURL) else {
                    print(pageURL + " failed to open")
                    return
                }
                UIApplication.shared.open(url)
                break
                
            case "DEFER_1HOUR_ACTION":
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
