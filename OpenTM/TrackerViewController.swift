//
//  SecondViewController.swift
//  OpenTM
//
//  Created by earmand on 11/5/18.
//  Copyright © 2018 Earman Consulting. All rights reserved.
//

import UIKit
import MapKit
import Files

class TrackerViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var trackerMapView: DEMapView!
    
    let locations = Locations.init()
    var runOnce     = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //trackerMapView.mapType = .mutedStandard
        trackerMapView.standardSetup()
        //trackerMapView.delegate = self
        
        
        trackerMapView.updateUserLocationAnnotationSubtitle()
        
        //let csvArray = CSV.csv("1,2,3")
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveOpenURL(_:)), name: NSNotification.Name(rawValue: "didReceiveOpenURL"), object: nil)
        
        
        testAnnotations()
        //testIcons()
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        
        // presentSettingsViewController()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // let deMapView = DEMapView.init()
        
        /*
         
         self.view.addSubview(deMapView)
         
         //deMapView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
         deMapView.translatesAutoresizingMaskIntoConstraints = false
         deMapView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
         deMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
         deMapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
         //deMapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant:-280).isActive = true
         deMapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant:0).isActive = true
         */
        
    }
    
    func dealloc () {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !runOnce {
            trackerMapView.setMapRegionToUserLocation(radiusMiles: 100)
            runOnce = true
        }
        
        loadKML()
        loadLitchiMissions()
    }
    
    
    @objc private func didReceiveOpenURL(_ notification: Notification) {
        
        if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)] : Called",0))  }
        
        if let url = notification.object as! URL? {
            
            if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)] : URL:%@",url.absoluteString))  }
            
            let fileExtension = url.pathExtension
            if fileExtension == "kml" {
                loadKml(url.path,zoom:true)
                
            } else if fileExtension == "csv" {
                loadCSV(url.path, zoom:true)
            }
        }
    }
    
    
    
    func loadKML() {
        do {
            let documentsFolder = try Folder.home.subfolder(named: "Documents")
            let dataFolder = try documentsFolder.subfolder(named: "kml")
            //let documentsFolder = try Folder.home.createSubfolder(named: "Documents")
            //let dataFolder = try documentsFolder.createSubfolderIfNeeded(withName: "kml")
            
            for file in dataFolder.files {
                print(file.name)
                
                loadKml(file.path)
            }
        } catch {
            print("Open KML Folder Error")
        }
    }
    
    fileprivate func loadKml(_ path: String, zoom:Bool=false) {
        
        KMLDocument.parse(url: URL.init(fileURLWithPath: path), callback: { [unowned self] (kml) in
            // Add overlays
            self.trackerMapView.addOverlays(kml.overlays)
            
            // Add annotations
            if zoom {
                self.trackerMapView.showAnnotations(kml.annotations, animated: true)
            } else {
                self.trackerMapView.addAnnotations(kml.annotations)
            }
            
            }
        )
        
    }

    
    
    
    func loadLitchiMissions () {
        
        let documentsFolder = try! Folder.home.createSubfolderIfNeeded(withName: "Documents")
        
        do {
            let csvFolder = try documentsFolder.createSubfolderIfNeeded(withName: "csv")
            
            for file in csvFolder.files {
                print("Load Litchi Mission:\(file.name)")
                
                loadCSV(file.path)
            }
            
        } catch {
            print("Open CSV Folder Error")
        }
    }
    
    fileprivate func loadCSV(_ path: String, zoom: Bool = false) {
        
        do {
            let contents = try String(contentsOf: URL.init(fileURLWithPath: path))
            //let csvArray = CSV.csv(contents)
            
            let litchiMission = try LitchiMission.init(missionString: contents)
            
            trackerMapView.addAnnotations(litchiMission.litchiMissionSteps)
            //trackerMapView.addAnnotations(litchiMission.annotations)
            trackerMapView.addOverlay(litchiMission.polyline)
            
            if zoom && litchiMission.coordinates.count > 0 {
                trackerMapView.setCenter(litchiMission.coordinates[0], animated: true)
            }
            print(contents)
        } catch {
            // contents could not be loaded
            print("Litchi Mission Conversion Error")
        }
    }

    func testAnnotations() {

        // Pikes Peak

        let homeScale = 0.9
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.homeCoord, title: "Home", subtitle: "4706 Broad Brook Dr",iconText: "DCE", color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale:homeScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.charlotteCoord, title: "Lauren", subtitle: "2301 Charlotte Dr",iconText: "LEE", color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale:homeScale))
        
        let placesScale = 0.7
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.barrTrailHead, title: "Barr Head", subtitle: "Trail Parking 6,676",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: placesScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.barrCamp, title: "Barr Camp", subtitle: "10,178(48%)",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: placesScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.pikesPeakCoord, title: "Pikes Peak", subtitle: "Summit 14,115'",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: placesScale))
        
        let ppScale = 0.7
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.pp1, title: "P1",   subtitle: "13,252' (89%)",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: ppScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.pp2, title: "P2",   subtitle: "12,589' (80%)",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: ppScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.pp3, title: "P3",   subtitle: "11,848' (70%)",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: ppScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.pp4, title: "P4",   subtitle: "11,130' (60%)",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: ppScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.pp5, title: "P5",   subtitle: "10,406' (50%)",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: ppScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.pp6, title: "P6",   subtitle: "9,764' (41%)",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: ppScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.pp7, title: "P7",   subtitle: "9,464' (37%)",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: ppScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.pp8, title: "P8",   subtitle: "9,164' (33%)",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: ppScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.pp9, title: "P9",   subtitle: "8,478' (24%)",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: ppScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.pp10, title: "P10", subtitle: "7,879' (16%)",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: ppScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.pp11, title: "P11", subtitle: "7,121' (5%)",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale: ppScale))
        
        
        
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.grandCanyonCoord, title: "Grand Canyon", subtitle: "",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale:placesScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.sedonaCoord, title: "Sedona", subtitle: "",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale:placesScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.campDavidCoord, title: "Camp David", subtitle: "",iconText: nil, color: UIColor.yellow, iconType: .rectCalloutFixedFont, scale:placesScale))
        
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.cabinLou, title: "Lou", subtitle: "Lou",iconText: "Lou", color: .yellow, iconType: .rectCalloutFixedFont, scale:placesScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.cabinEarman, title: "Cabin", subtitle: "Cabin",iconText: "Cabin", color: .yellow, iconType: .rectCalloutFixedFont, scale:placesScale))
        
        let airportScale = 0.7
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.bwiCoord, title: "BWI", subtitle: "BWI",iconText: "BWI",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.choCoord, title: "CHO", subtitle: "Charlottesville–Albemarle Airpor",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.andrewsAFBCoord, title: "Andrews AFB", subtitle: "Andrews Air Force Base",iconText: "ADW", color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.leesburgAirparkCoord, title: "Leesburg ", subtitle: "Leesburg Airport",iconText: "JYO",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.dcaCoord, title: "DCA", subtitle: "Reagan National Airport",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.iadCoord, title: "IAD", subtitle: "Dulles Airport",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.cbeCoord, title: "CBE", subtitle: "Cumberland",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.gaiCoord, title: "GAI", subtitle: "Montgomery Airpark",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.grrCoord, title: "GRR", subtitle: "Grand Rapids",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.cltCoord, title: "CLT", subtitle: "Charlotte",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.sdfCoord, title: "SDF", subtitle: "Louisville",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.bnaCoord, title: "BNA", subtitle: "Nashville",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.denCoord, title: "DEN", subtitle: "Denver",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.atlCoord, title: "ATL", subtitle: "Hartsfield-Jackson Atlanta",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.rtbCoord, title: "RTB", subtitle: "Roatan Juan Manuel Galvez",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.dovCoord, title: "DOV", subtitle: "Dover AFB",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.ewrCoord, title: "EWR", subtitle: "Newark",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.lgaCoord, title: "LGA", subtitle: "Laguardia",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.jfkCoord, title: "JFK", subtitle: "JFK",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.bosCoord, title: "BOS", subtitle: "Boston",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.mdwCoord, title: "MDW", subtitle: "Midway",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.ordCoord, title: "ORD", subtitle: "Chicago",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.miaCoord, title: "MIA", subtitle: "Miami",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.gcmCoord, title: "GCM", subtitle: "Grand Caymen",  color: .orange, iconType: .rectangle, scale:airportScale))
        
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.sfoCoord, title: "SFO", subtitle: "San Francisco",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.oakCoord, title: "OAK", subtitle: "Oakland",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.laxCoord, title: "LAX", subtitle: "LAX",  color: .orange, iconType: .rectangle, scale:airportScale))
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.dvlCoord, title: "DVL", subtitle: "UAV Test Site",  color: .orange, iconType: .rectangle, scale:airportScale))
        
        trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.walterReedMedicalHeliportCoord, title: "WR", subtitle: "Walter Reed Medical Heliport",  color: .orange, iconType: .rectangle, scale:airportScale))


        

        //trackerMapView.addAnnotation(DEMapAnnotation.init(coordinate: locations.charlotteCoord, title: "Charlotte", subtitle: "",iconText: "Charlotte\nAirport\nKCLT\nTest", color: UIColor.green, iconType: .rectCalloutFixedFont, scale:1.0))
        
    }
    
    
    
    func testIcons () {
        
        let image = DEImage.createRectIconImage(with: "ABC", color: .red, scale: 2.0)
        
        let image2 = DEImage.createRectIconImage(with: "ABCDEF", color: .red, scale: 1.0)
        let image3 = DEImage.createRectIconImage(with: "ABCDEF", color: .red, scale: 2.0)
        let image4 = DEImage.createRectIconImage(with: "ABCDEF", color: .red, scale: 0.5)
        
        let image5 = DEImage.createRectIconImage(with: "ABCDEFGHIJKL", color: .blue, scale: 100.0)
        
        
        let timage1 = DEImage.createTearIconImage(with: "1", color: .blue , scale: 1.0)
        let timage2 = DEImage.createTearIconImage(with: "1", color: .red , scale: 2.0)
        let timage3 = DEImage.createTearIconImage(with: "A", color: .yellow , scale: 3.0)
        let timage4 = DEImage.createTearIconImage(with: "AA", color: .yellow , scale: 3.0)
        let timage5 = DEImage.createTearIconImage(with: "♕", color: .yellow , scale: 3.0)
        let timage6 = DEImage.createTearIconImage(with: "😃", color: .yellow , scale: 3.0)
        
        print("Image")
        

    }
    
    
    func presentSettingsViewController () {
        let viewController : DEMapViewSettingTableViewController = UIStoryboard(name: "DEMapViewStoryboard", bundle: nil).instantiateInitialViewController() as! DEMapViewSettingTableViewController
        // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
        
        viewController.modalPresentationStyle = .popover
        viewController.deMapView = self.trackerMapView
        
        //self.navigationController?.pushViewController(viewController, animated: true)
        self.present(viewController, animated: false, completion: nil)

        
        let popController : UIPopoverPresentationController = viewController.popoverPresentationController!
        popController.permittedArrowDirections = .up
        popController.barButtonItem = UIBarButtonItem.init()
        
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissPopover))
       // let nav = UINavigationController(rootViewController: viewController.presentedViewController!)
        self.navigationController!.topViewController?.navigationItem.leftBarButtonItem = btnDone
        
        popController.delegate = self
        
    }

    
    
    // MARK: - Prepare for Seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)]  -%@",segue.identifier!))  }
        if segue.identifier == "DEMapViewSettingViewController" {
            
            //
            
            segue.destination.popoverPresentationController?.delegate = self
            if let vc = segue.destination as? DEMapViewSettingTableViewController {
                if let path = Bundle.main.path(forResource: "MapSettings", ofType: "plist", inDirectory: "Settings.bundle"),
                    let dictionary = NSDictionary(contentsOfFile: path){
                    vc.preferenceDictionary = dictionary
                }
                vc.deMapView = self.trackerMapView
            }
            return

        }
    }
    
    
    //* Required Delegates
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        return trackerMapView.mapView(mapView, regionDidChangeAnimated: animated)
        
    }

    
/*
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let zoomWidth = mapView.visibleMapRect.size.width
        let zoomFactor = Int(log2(zoomWidth)) - 9
        print("...REGION DID CHANGE: ZOOM FACTOR \(zoomFactor)")
    }
*/
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)] User Overlay Handler -%02d",0))  }
        return trackerMapView.mapView(mapView, rendererFor: overlay)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return trackerMapView.mapView(mapView, viewFor: annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        return trackerMapView.mapView(mapView,  didSelect: view)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        return trackerMapView.mapView(mapView,  didDeselect: view)
    }
    


}

extension TrackerViewController: UIPopoverPresentationControllerDelegate {
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.dismissPopover))
        let nav = UINavigationController(rootViewController: controller.presentedViewController)
        nav.topViewController?.navigationItem.leftBarButtonItem = btnDone
        return nav
    }
    
    @objc private func dismissPopover() {
        dismiss(animated: true, completion: nil)
    }
    
}


class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

