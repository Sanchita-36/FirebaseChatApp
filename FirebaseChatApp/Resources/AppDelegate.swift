//
//  AppDelegate.swift
//  FirebaseChatApp
//
//  Created by Sanchita Lachke on 23/11/22.
//

import UIKit
import FirebaseCore
import FacebookCore
import GoogleSignIn
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //For Firebase
        FirebaseApp.configure()
        
        //For Facebook
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error  == nil else {
            if let error = error {
                print("Failed to sign in with google - \(error)")
            }
            return
        }
        
        guard let user = user else { return }
        print("Did sign in with google- \(user)")
        
        guard  let email = user.profile.email, let firstName = user.profile.givenName, let lastName = user.profile.familyName else{ return }
        
        
        DatabaseManager.shared.userExists(with: email) { exists in
            if !exists {
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
            }
        }
        
        guard let authentication = user.authentication else  {
            print("Missing auth object off of google")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in

            guard authResult != nil, error == nil else {
                if let error = error {
                    print("Failed to login with google credentials - \(error)")
                }
                return
            }
            
            print("Successfully Sign in with google credentials.")
            
            NotificationCenter.default.post(name: .didLoginNotification, object: nil)
        }
    }

func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    print("Google user was disconnected")
}

func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    
    ApplicationDelegate.shared.application(
        UIApplication.shared,
        open: url,
        sourceApplication: nil,
        annotation: [UIApplication.OpenURLOptionsKey.annotation]
    )
    
    return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
}

// MARK: UISceneSession Lifecycle

func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
}

func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


}

