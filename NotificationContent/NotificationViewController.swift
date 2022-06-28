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
class NotificationViewController: NSHostingController<PipelineView>, UNNotificationContentExtension {
    @objc required dynamic init?(coder: NSCoder) {
        super.init(coder: coder, rootView: PipelineView(stages: []))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func didReceive(_ notification: UNNotification) {
        if let jsonData = notification.request.content.userInfo["PIPELINE_STATUS"] as? Data,
           let headPipeline = try? JSONDecoder().decode(HeadPipeline.self, from: jsonData) {
            // should display
            self.rootView = PipelineView(stages: headPipeline.stages?.edges?.map({ $0.node }) ?? [])
        }
    }
}
