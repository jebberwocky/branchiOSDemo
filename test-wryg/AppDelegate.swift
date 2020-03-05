//
//  AppDelegate.swift
//  test-wryg
//
//  Created by Jeff Liu on 11/9/18.
//  Copyright © 2018 Jeff Liu. All rights reserved.
//

import UIKit
import Branch
import Firebase
import AdSupport

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var branchCPID: String = "cpid-nil"
    
    var branch_param_value: String = ""

    func identifierForAdvertising() -> String? {
        // Check whether advertising tracking is enabled
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil
        }

        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Firebase
        FirebaseApp.configure()
        
        Branch.getInstance().setDebug()
        //Branch.getInstance().validateSDKIntegration()
        let branch: Branch = Branch.getInstance()
        
        
        print("IDFA: ", identifierForAdvertising());
        
        
       // branch.setDebug()
        branch.setRequestMetadataKey("your_device_id",value:"UUID_JEFF_LIU")
        branch.setRequestMetadataKey("after_empty",value:"after_empty")
        print("getLongURL")
        print(Branch.getInstance().getLongURL(withParams:nil))
       
        branch.initSession() { (params, error) in
        
            print("initSession called")
            print(params as? [String: AnyObject] ?? {})
            do{
            let arrJson = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
                self.branch_param_value = String(data: arrJson, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            }catch let error as NSError{
               print(error.description)
           }
            branch.setIdentity("UUID_JEFF_LIU")
            
            guard let paramsDictionary = (params as? Dictionary<String, Any>),
                let clickedBranchLink = paramsDictionary[BRANCH_INIT_KEY_CLICKED_BRANCH_LINK] as? Bool
                else {
                    print("No Branch parameters returned")
                    return
            }
            
            if(error == nil && params != nil){
                 // create and add properties that you want to track in Firebase
                 var firebase_params = [String: Any]()
                 firebase_params["clicked_branch_link"] =  params?["+clicked_branch_link"] ?? ""
                 // get the click timestamp
                 firebase_params["click_timestamp"] = params?["+click_timestamp"] ?? ""
                 // get the link OG title
                 firebase_params["link_title"] = params?["$og_title"] ?? ""
                 // get the link OG image
                 firebase_params["link_image"] =  params?["$og_image_url"] ?? ""
                 // get the link campaign
                 firebase_params["utm_campaign"] = params?["~campaign"] ?? ""
                 // get the link channel
                 firebase_params["utm_medium"] = params?["channel"] ?? ""
                 // get the link feature
                 firebase_params["utm_source"] = params?["~feature"] ?? ""
                 // check if this is an open or and install event
                 if(UserDefaults.standard.object(forKey: "is_first_session") == nil){
                   UserDefaults.standard.set(true, forKey: "is_first_session")
                 }
                               else{
                   UserDefaults.standard.set(false, forKey: "is_first_session")
                 }
                 let event_name = UserDefaults.standard.bool(forKey: "is_first_session") == true ? "branch_install" : "branch_open"
                 // track the event to Firebase
                 Analytics.logEvent(event_name, parameters: firebase_params)
               }
            
            //LATD
            Branch.getInstance().lastAttributedTouchData(withAttributionWindow: 7) { (data)->() in
               print("LATD")
               let latd = data as? BranchLastAttributedTouchData
               if(latd != nil){
                   let _json = latd?.lastAttributedTouchJSON
                    print(_json)
               }
           }
            
            
            if (paramsDictionary["$3p"] != nil && paramsDictionary["$web_only"] != nil) {
                let url = paramsDictionary["$original_url"] as? String
                print(url as? String)
            }
            
            let canonicalUrl = paramsDictionary["$canonical_url"] as? String
            print(canonicalUrl as? String)
            if clickedBranchLink && canonicalUrl != nil {
                /*
                let nc = self.window!.rootViewController as! UINavigationController
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let webViewController = storyboard.instantiateViewController(withIdentifier: "Web") as! WebViewViewController
                nc.popToRootViewController(animated: true)
                print(canonicalUrl!);
                if(!canonicalUrl!.isEmpty)
                {
                    webViewController.passedURL = canonicalUrl!
                    nc.pushViewController(webViewController, animated: true)
                }
                let urlsplits = canonicalUrl!.split(separator: "?");
                
                if (canonicalUrl != nil  && urlsplits.count > 1){
                    let requestPramas = canonicalUrl!.split(separator: "?")[1].split(separator: "&")
                    var partnerURL = ""
                    for dics in requestPramas{
                        
                        let key = dics.split(separator: "=")[0]
                        print(key);
                        if key == "partner"{
                            partnerURL = String(dics.split(separator: "=")[1])
                            
                            
                            
                            let nc = self.window!.rootViewController as! UINavigationController
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let webViewController = storyboard.instantiateViewController(withIdentifier: "Web") as! WebViewViewController
                            nc.popToRootViewController(animated: true)
                            print(partnerURL);
                            if(!partnerURL.isEmpty)
                            {
                                webViewController.passedURL = partnerURL
                                nc.pushViewController(webViewController, animated: true)
                            }
                        }
                    }
                }*/
            }
            
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("application open url:")
        print(url.absoluteURL)
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // handler for Push Notifications
        Branch.getInstance().handlePushNotification(userInfo)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("Enter foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
         print("Enter Active")
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

