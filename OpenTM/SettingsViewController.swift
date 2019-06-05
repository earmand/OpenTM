//
//  SettingsViewController.swift
//  OpenTM
//
//  Created by earmand on 11/17/18.
//  Copyright © 2018 Earman Consulting. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var preferenceDictionary : NSDictionary?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "DEMapViewStoryboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DEMapViewSettingTableViewController")
        self.present(controller, animated: true, completion: nil)
        
    }
    
    
    
    func viewDidLoadold() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        preferenceDictionary = NSDictionary.dictionary(from: "MapSettings", withExtension: "plist")
        print(preferenceDictionary)
    
        //let userDefaults = UserDefaults.standard
       // userDefaults.register(defaults: preferenceDictionary as! [NSObject : AnyObject])  // with or without this code works... do I need this?
        //userDefaults.synchronize()
        
        registerDefaultsFromSettingsDictionary(preferenceDictionary!)
        
        
       
        
        let prefType : NSDictionary.PreferenceType = (preferenceDictionary?.preferenceType())!
        if prefType == .preferenceSpecifiers {
            print("good")
            print (preferenceDictionary?.numberOfSections())
        }
        
        print(prefType)
    
    }
    
    
    // MARK: - Prepare for Seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)]  -%@",segue.identifier!))  }
        if segue.identifier == "DEMapViewSettingViewController" {
            
            //
            
            //segue.destination.popoverPresentationController?.delegate = self
            if let vc = segue.destination as? DEMapViewSettingTableViewController {
                if let path = Bundle.main.path(forResource: "MapSettings", ofType: "plist", inDirectory: "Settings.bundle"),
                    let dictionary = NSDictionary(contentsOfFile: path){
                    vc.preferenceDictionary = dictionary
                }
               // vc.deMapView = self.trackerMapView
            }
            return
            
        }
    }
    
    func registerDefaultsFromSettingsDictionary(_ settingsDictionary : NSDictionary)
    {
        //let settingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
        //let settingsPlist = NSDictionary(contentsOf:settingsUrl)!
        let preferences = settingsDictionary["PreferenceSpecifiers"] as! [NSDictionary]
        
        var defaultsToRegister = Dictionary<String, Any>()
        
        for preference in preferences {
            guard let key = preference["Key"] as? String else {
                NSLog("Key not fount")
                continue
            }
            defaultsToRegister[key] = preference["DefaultValue"]
        }
        UserDefaults.standard.register(defaults: defaultsToRegister)
    }
    
}


extension SettingsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        //view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        view.tintColor = UIColor.init(white: 0.9, alpha: 1.0)
        view.layer.borderColor = UIColor.init(white:0.85,alpha:1.0).cgColor
        //view.layer.borderColor = [UIColor redColor].CGColor;
        view.layer.borderWidth = 0.5;
        //view.tintColor = UIColor.blue
        //view.backgroundColor = UIColor.blue
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.adjustsFontSizeToFitWidth = false
        header.textLabel?.font = UIFont.systemFont(ofSize: 15)
        header.textLabel?.textColor = UIColor.darkGray
        header.textLabel?.text = header.textLabel?.text?.uppercased()
        //header.textLabel?.textAlignment = .center
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return preferenceDictionary?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return preferenceDictionary?.numberOfRowsInSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return preferenceDictionary?.titleForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaults    = UserDefaults.standard
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell2", for: indexPath)
        if let cell =  cell as? LabelCell2 {
            
            if let dictionary = preferenceDictionary?.dictionaryForRowAtIndexPath(indexPath: indexPath) {
                if let title = dictionary["Title"] as! String? ,
                    let type = dictionary["Type"] as! String? ,
                    let key = dictionary["Key"] as! String?{
                    
                    if type == "PSToggleSwitchSpecifier" {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell2", for: indexPath)
                        if let cell =  cell as? SwitchCell2 {
                            cell.title.text = title
                            cell.key = key
                            
                            let bool = defaults.bool(forKey: key)
                            cell.uiSwitch.isOn = bool

                            return cell
                        }
                 
                    } else {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell2", for: indexPath)
                        if let cell =  cell as? LabelCell2 {
                            cell.title.text = title
                            return cell
                        }
                    }
                    
                }
            }
            
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: "labelCell2", for: indexPath)
    }
    
}


class LabelCell2: UITableViewCell {
    @IBOutlet var title: UILabel!
}


class SwitchCell2: UITableViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var uiSwitch: UISwitch!
    var key : String?
    
    @IBAction func valueChanged(_ sender: Any) {
        let sender = sender as! UISwitch
        print("SwitchValueChanged:\(sender.isOn)")
        
        UserDefaults.standard.set(sender.isOn, forKey: key!)
        //returnValue?(sender.isOn)
    }
    
    
    
    
}
