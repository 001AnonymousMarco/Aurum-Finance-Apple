//
//  Aurum_FinanceApp.swift
//  Aurum Finance
//
//  Created by Marc Alleyne on 7/7/25.
//

import SwiftUI
import FirebaseCore

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
#endif

@main
struct Aurum_FinanceApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif
    
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    init() {
        #if os(macOS)
        // Configure Firebase for macOS
        FirebaseApp.configure()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if firebaseManager.isAuthenticated {
                    ContentView()
                } else {
                    AuthView()
                }
            }
            #if os(macOS)
            .background(Color.aurumDark)
            .frame(minWidth: 1000, minHeight: 700)
            #endif
        }
        #if os(macOS)
        .windowStyle(.automatic)
        .windowResizability(.automatic)
        .defaultSize(width: 1200, height: 800)
        #endif
    }
}
