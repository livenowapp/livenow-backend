//
//  LiveNowApp.swift
//  LiveNow
//
//  Created by Gregor Cigoj on 23. 4. 2026.
//

import SwiftUI
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        FirebaseApp.configure()
        return true
    }
}

@main
struct LiveNowApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
