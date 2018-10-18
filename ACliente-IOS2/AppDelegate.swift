//
//  AppDelegate.swift
//  ACliente-IOS2
//
//  Created by adrian aguilar on 12/10/18.
//  Copyright © 2018 altura s.a. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import GoogleMaps
import SQLite
import FirebaseCore
import FirebaseMessaging
import FirebaseInstanceID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    let dbase = DBase();
    var db: Connection!
    let ws = WService();


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge], completionHandler: {idGranted, err in
            if err != nil{
                print("se genero error de autorizacion de notificacion: \(String(describing: err))")
            }else{
                print("entra en else app delegte")
                UNUserNotificationCenter.current().delegate = self
                Messaging.messaging().delegate = self
                
                let token = Messaging.messaging().fcmToken
                print("FCM token para registro en base: \(token ?? "")")
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateBadge), name: NSNotification.Name(rawValue: "applicationIconBadgeNumber"), object: nil)
        
        //configuracion inicial de firebase
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyD9zVbkyxSGE0swMdmBeQ2-8G9fz1zghZQ")
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        return true
    }
    
    func connectToFirebaseMessage(){
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        if let token = InstanceID.instanceID().token() {
            print("DCS: " + token)
        }
    }
    
    func disconnectToFirebaseMessage(){
        Messaging.messaging().shouldEstablishDirectChannel = false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        disconnectToFirebaseMessage()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        connectToFirebaseMessage()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        connectToFirebaseMessage()
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        print("entra en app finish")
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let status = dbase.connect_db()
        if( status.value ){
            self.db = status.conec
            
            let user_temp = dbase.loadUsersDB()
            var internet = false
            if Connectivity.isConnectedToInternet {
                print("Connected")
                internet = true
            }
            
            if user_temp.error == 0 && internet {
                
                print("usuario logeado, encontrado desde backgroud")
                notificationPop(title: "user logeado", subtitle: "sub de user log", body: "prueba de backgound")
                let notificationsList = dbase.getNotifications()
                let accounts = dbase.getAccounts()
                
                self.updateNotifications(notificationsList: notificationsList, user_temp: user_temp, success: {
                    (status) -> Void in
                    if status{
                        print("ok notifications")
                    }else{
                        print("err notifications")
                    }
                })
                self.updateDataCore(accounts: accounts, user_in: user_temp, success: {
                    (status) -> Void in
                    if status{
                        notificationPop(title: "Interagua", subtitle: "SUCCESS", body: "Se actualizó la información detallada de las cuentas")
                        completionHandler(.newData)
                        
                    }else{
                        notificationPop(title: "Interagua", subtitle: "ERROR", body: "Se generó un error al actualizar la data detallada de las cuentas")
                        completionHandler(.noData)
                    }
                })
                
            }else{
                completionHandler(.noData)
            }
        }
        
    }
    
    func updateNotifications(notificationsList: [notification],user_temp: User, success: @escaping (_ status: Bool) -> Void){
        
        self.ws.loadNotifications(id_user: String(describing: user_temp.id_user), date: user_temp.sync_date,
                                  success: {
                                    (notifications) -> Void in
                                    print("ok notificacion")
                                    
                                    var newNotifications = [notification]()
                                    for item in notifications{
                                        let tipo = item.type
                                        let message = item.message
                                        var existe = false
                                        for item2 in notificationsList{
                                            if item2.type == tipo && item2.message == message {
                                                existe = true
                                            }
                                        }
                                        if !existe{
                                            newNotifications.append(item)
                                        }
                                    }
                                    
                                    for item in newNotifications{
                                        notificationPop(title: "Interagua", subtitle: item.date_gen, body: item.message)
                                    }
                                    
                                    if newNotifications.count > 0{
                                        DispatchQueue.main.async {
                                            self.dbase.insertNotifications(notificationsList: newNotifications)
                                        }
                                    }
                                    success(true)
        },error: {
            (accounts,message) -> Void in
            success(false)
        })
        
    }
    
    func updateDataCore( accounts: [account], user_in: User, success: @escaping (_ status: Bool) -> Void){
        
        self.ws.loadCore(id_user: String(describing: user_in.id_user), accounts: accounts,
                         success: {
                            (notifications) -> Void in
                            print("data actualizada mediante background")
                            success(true)
                            
        },error: {
            (accounts,message) -> Void in
            
            print("error al actualizar data mediante background, \(message)")
            success(false)
            
        })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print(" conteo de icono: \(UIApplication.shared.applicationIconBadgeNumber)")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "applicationIconBadgeNumber"), object: nil)
        
        completionHandler([.alert, .badge])
    }
    
    @objc func updateBadge(){
        UIApplication.shared.applicationIconBadgeNumber += 1
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ACliente_IOS2")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

