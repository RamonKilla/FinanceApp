//
//  FinanceApp.swift
//  Finance
//
//  Created by Ivan on 08.03.2023.
//

import SwiftUI
import AuthenticationServices
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
@main
struct FinanceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
    }
}
