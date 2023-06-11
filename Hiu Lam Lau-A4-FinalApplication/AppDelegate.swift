//
//  AppDelegate.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 6/4/2023.
//
// Reference 2 Set Window’s Root View Controller in Swift: https://www.appsdeveloperblog.com/set-windows-root-view-controller-in-swift/

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var databaseController: DatabaseProtocol?
    var blogDatabaseController: DatabaseProtocolBlog?
    var recordDatabaseController: DatabaseProtocolRecord?
    var window: UIWindow?
    
    //bar
//    var persistentContainer: NSPersistentContainer!
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "BalanceRecordModel")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        databaseController = CoreDataController()
        blogDatabaseController = BlogCoreDataController()
        recordDatabaseController = RecordCoreDataController()

        return true
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

