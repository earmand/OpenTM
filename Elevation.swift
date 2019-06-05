//
//  Elevation.swift
//  OpenTM
//
//  Created by Daniel Earman on 4/5/19.
//  Copyright © 2019 Earman Consulting. All rights reserved.
//

import Foundation
import MapKit

class ElevationTileMgr {
    func elevationTile(forPath: MKTileOverlayPath) -> Data? {
        return nil
    }
    
    func elevationTile(at path: MKTileOverlayPath, forTileData tileData: Data?) -> Data? {
        return nil
    }
    
    func location(forCoordinate coordinate: CLLocationCoordinate2D, completionHandler: @escaping (_ location: CLLocation?, _ error: Error?) -> Void) {
        
    }
    
    func location(forMapPoint mapPoint: MKMapPoint, completionHandler: @escaping (_ location: CLLocation?, _ error: Error?) -> Void) {
        
    }
    
    func elevationArray(forCoordinates coordinates: [CLLocationCoordinate2D], completionHandler: @escaping (_ locationArray: [CLLocation], _ error: Error?) -> Void) {
    }
    
}


class ElevationTile : NSData {

    func mapElevationTile(fromPath: MKTileOverlayPath, toPath: MKTileOverlayPath) -> Data? {
        return nil
    }
    
    
}

extension Data {
    
    func mapElevationTile(fromPath: MKTileOverlayPath, toPath: MKTileOverlayPath) -> Data? {
        return self
    }

    
}


class ElevationTileOverlay: MKTileOverlay {
}
