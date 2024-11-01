//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by Stef Kors on 27/06/2022.
//

import Cocoa
import UserNotifications
import UserNotificationsUI

import SwiftUI

/// https://developer.apple.com/documentation/usernotificationsui/customizing_the_appearance_of_notifications
class NotificationViewController: NSHostingController<CIJobsNotificationView>, UNNotificationContentExtension {
    @objc required dynamic init?(coder: NSCoder) {
        super.init(coder: coder, rootView: CIJobsNotificationView(stages: []))
    }

    func didReceive(_ notification: UNNotification) {
        if let jsonData = notification.request.content.userInfo["PIPELINE_STATUS"] as? Data,
           let headPipeline = try? JSONDecoder().decode(GitLab.HeadPipeline.self, from: jsonData) {
            self.rootView = CIJobsNotificationView(stages: headPipeline.stages?.edges?.map({ $0.node }) ?? [])
        }
    }
}
