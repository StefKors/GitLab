//
//  MediumLaunchPadWidgetView.swift
//  DesktopWidgetToolExtension
//
//  Created by Stef Kors on 26/04/2024.
//

import SwiftUI

struct MediumLaunchPadWidgetView: View {
    let repos: [LaunchpadRepo]
    
    var body: some View {
        ViewThatFits {
            WrappingHStack {
                WidgetLaunchPadRow(repos: repos, length: 10)
            }
            
            WrappingHStack {
                WidgetLaunchPadRow(repos: repos, length: 9)
            }
            
            WrappingHStack {
                WidgetLaunchPadRow(repos: repos, length: 8)
            }
            
            WrappingHStack {
                WidgetLaunchPadRow(repos: repos, length: 7)
            }
            
            WrappingHStack {
                WidgetLaunchPadRow(repos: repos, length: 6)
            }
            
            WrappingHStack {
                WidgetLaunchPadRow(repos: repos, length: 5)
            }
            
            WrappingHStack {
                WidgetLaunchPadRow(repos: repos, length: 4)
            }
            
            WrappingHStack {
                WidgetLaunchPadRow(repos: repos, length: 3)
            }
            
            WrappingHStack {
                WidgetLaunchPadRow(repos: repos, length: 2)
            }
            
            WrappingHStack {
                WidgetLaunchPadRow(repos: repos, length: 1)
            }
        }
    }
}

#Preview {
    MediumLaunchPadWidgetView(repos: [])
}