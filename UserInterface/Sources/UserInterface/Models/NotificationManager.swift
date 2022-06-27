//
//  NotificationManager.swift
//  
//
//  Created by Stef Kors on 24/06/2022.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager {

    static var shared = NotificationManager()
    var delegate = GitLabNotificationDelegate()

    init () {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        registerApprovalAction()
        UNUserNotificationCenter.current().delegate = delegate
    }

    func registerApprovalAction() {
        // Define the custom actions.
        let acceptAction = UNNotificationAction(
            identifier: "OPEN_URL",
            title: "Open",
            options: []
        )


        // Define the notification type
        let mrApprovalCategory = UNNotificationCategory(
            identifier: "MR_EVENT",
            actions: [acceptAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "%u Merge requests",
            categorySummaryFormat: "Multiple merge request updates",
            options: .customDismissAction
        )
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([mrApprovalCategory])
    }

    func sendNotification(title: String, subtitle: String?, userInfo: [AnyHashable : Any]? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title

        if let subtitle = subtitle {
            content.subtitle = subtitle
        }

        if let userInfo = userInfo {
            content.userInfo = userInfo
        }

        content.categoryIdentifier = "MR_EVENT"

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
}


class GitLabNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    @Environment(\.openURL) private var openURL

    // func userNotificationCenter(
    //     _ center: UNUserNotificationCenter,
    //     willPresent notification: UNNotification,
    //     withCompletionHandler completionHandler:
    //     @escaping (UNNotificationPresentationOptions) -> Void
    // ) {
    //     if notification.request.content.categoryIdentifier == "MR_EVENT" {
    //         // Retrieve the meeting details.
    //         // let meetingID = notification.request.content.userInfo["MEETING_ID"] as! String
    //         // let userID = notification.request.content.userInfo["USER_ID"] as! String
    //
    //         // Add the meeting to the queue.
    //         // sharedMeetingManager.queueMeetingForDelivery(user: userID, meetingID: meetingID)
    //
    //
    //         // Play a sound to let the user know about the invitation.
    //         completionHandler(.sound)
    //         return
    //     }
    //     else {
    //         // Handle other notification types...
    //     }
    //
    //
    //     // Don't alert the user for other types.
    //     completionHandler(UNNotificationPresentationOptions(rawValue: 0))
    // }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler:
        @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let urlString = userInfo["MR_URL"] as? String,
              let url = URL(string: urlString) else {
            completionHandler()
            return
        }


        // Perform the task associated with the action.
        switch response.actionIdentifier {
        case "OPEN_URL":
            openURL(url)
            break

        default:
            openURL(url)
            break
        }
        // Always call the completion handler when done.
        completionHandler()
    }
}
