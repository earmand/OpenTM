//
//  AppDelegate.swift
//  OpenTM
//
//  Created by earmand on 11/5/18.
//  Copyright © 2018 Earman Consulting. All rights reserved.
//

import UIKit
import Files

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        var clearFolders : [String] = []
        //clearFolders.append("csv")
        //clearFolders.append("kml")
        //clearFolders.append("Inbox")
        // test
        
        for folderName in clearFolders {
            do {
                let documentsFolder = try Folder.home.subfolder(named: "Documents")
                let dataFolder = try documentsFolder.subfolder(named: folderName)
                //let documentsFolder = try Folder.home.createSubfolder(named: "Documents")
                //let dataFolder = try documentsFolder.createSubfolderIfNeeded(withName: "kml")
                print("Folder: \(folderName)")
                for file in dataFolder.files {
                    print("  deleted File: \(file.name)")
                    try file.delete()
                }
            } catch {
                print("Clear Folder Failed: \(folderName)")
            }
        }
        
        return true
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)] : URL:%@",url.absoluteString))  }
        
        // let folder = try! Folder.home.createSubfolderIfNeeded(withName: "kml")
        
        let documentsFolder = try! Folder.home.createSubfolderIfNeeded(withName: "Documents")

        let srcFile = try! File.init(path: url.path)
        var dstFile : File?
        
        let fileExtension = url.pathExtension
        if fileExtension == "kml" {
            let kmlFolder = try! documentsFolder.createSubfolderIfNeeded(withName: "kml")
            dstFile = try? srcFile.copy(to: kmlFolder)
        
        } else if fileExtension == "csv" {
            let csvFolder = try! documentsFolder.createSubfolderIfNeeded(withName: "csv")
            dstFile = try? srcFile.copy(to: csvFolder)
        }
        
        do {
            try FileManager.default.removeItem(at: url)
            print("Deleted URL:\(url.path)")
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
 
/*
        kmlFolder.makeSubfolderSequence(recursive: true).forEach { folder in
            print("Name : \(folder.name), parent: \(folder.parent)")
        }
*/
        if let dstFile = dstFile {
            NotificationCenter.default.post(name:NSNotification.Name(rawValue: "didReceiveOpenURL"), object: URL.init(fileURLWithPath: dstFile.path))
            
            do {
                let contents = try String(contentsOf: url)
                print("URL:\(url.path)")
                //print(contents)
            } catch {
                // contents could not be loaded
            }
        }
        
        
        return true
    }


}

