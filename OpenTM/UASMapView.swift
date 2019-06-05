//
//  FirstViewController.swift
//  OpenTM
//
//  Created by earmand on 11/5/18.
//  Copyright © 2018 Earman Consulting. All rights reserved.
//

import UIKit
import MapKit


class UASMapView: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        mapView.standardSetup()
        mapView.mapType = MKMapType(rawValue: 0)!
        // Do any additional setup after loading the view, typically from a nib.
        
        UserDefaults.standard.addObserver(self, forKeyPath: "notifyAircraft", options: [.old,.new], context: nil)
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let zoomWidth = mapView.visibleMapRect.size.width
        let zoomFactor = Int(log2(zoomWidth)) - 9
        print("...REGION DID CHANGE: ZOOM FACTOR \(zoomFactor)")
        
    }
    
    
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "Gift")
        //NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
/*
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        //setGiftCount()
    }
*/
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        switch keyPath {
        case "notifyAircraft" :
            let old = change![NSKeyValueChangeKey.oldKey] as? Bool ?? false
            let new = change![NSKeyValueChangeKey.newKey] as! Bool
            print("Defaults Updated : from: \(old) to:\(new)")

            

        default :
            print("keyPath undefined")

        }
    }

    
    @objc func userDefaultsDidChange(_ notification: Notification) {
        // your code...   setGiftCount()
        print(notification)
    }
    

}

