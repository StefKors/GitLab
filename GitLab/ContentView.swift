//
//  ContentView.swift
//  GitLab
//
//  Created by Stef Kors on 13/09/2021.
//

import SwiftUI

struct ContentView: View {
    @StateObject var networkManager = NetworkManager()
    var body: some View {
        Text("\(networkManager.mergeRequests.count)")
            .onAppear {
                networkManager.name()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
