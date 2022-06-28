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
import UserInterface

/// https://developer.apple.com/documentation/usernotificationsui/customizing_the_appearance_of_notifications
class NotificationViewController: NSHostingController<CIStatusView>, UNNotificationContentExtension {
    @objc required dynamic init?(coder: NSCoder) {
        super.init(coder: coder, rootView: CIStatusView(status: .pending))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func didReceive(_ notification: UNNotification) {
        print("custom notification")
        print(notification.request.content.categoryIdentifier)

        if let status = notification.request.content.userInfo["PIPELINE_STATUS"] as? String {
            // should display
            self.rootView = CIStatusView(status: PipelineStatus(rawValue: status))
        }
    }
}
