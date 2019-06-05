//  Converted to Swift 4 by Swiftify v4.2.6866 - https://objectivec2swift.com/
//
//  LidarTileOverlay.swift
//  UTM
//
//  Created by earmand on 2/2/17.
//  Copyright © 2017 Earman Consulting. All rights reserved.
//  Save

//
//  LidarTileOverlay.swift
//  UTM
//
//  Created by earmand on 2/2/17.
//  Copyright © 2017 Earman Consulting. All rights reserved.
//
//
// Note: Tiles are 256*256*2bytes   => 128K bytes


import MapKit

class LidarTileOverlay: MKTileOverlay {
    let debug = false
    
    let perfTest = false
    var perfData : Data? = nil
    var perfImg  : Data? = nil
    
    var tileOverlayRenderer: MKTileOverlayRenderer?

    /*Base Altitude: Meters (Absolute) */
    enum BaseAltitudeReference: Int {
        case userSpecified = 0
        case userLocation = 1
        case selectedVehicle = 2
        case selectedCoordinate = 3
    }
    
    
    private var _baseAltitudeReference: BaseAltitudeReference = .userSpecified
    var baseAltitudeReference: BaseAltitudeReference {
        get {
            return _baseAltitudeReference
        }
        set(baseAltitudeReference) {
            if (_baseAltitudeReference != baseAltitudeReference) {
                _baseAltitudeReference = baseAltitudeReference
                refreshData()
            }
        }
    }
    
    
    /*Base Altitude: Meters (Absolute) */
    private var _baseElevation: CLLocationDistance = 0
    var baseElevation: CLLocationDistance {
        get {
            return _baseElevation
        }
        set(baseElevation) {
            _baseElevation = baseElevation
    
            if abs(Float(_baseElevation - displayedElevation)) > Float(baseElevationChangeThreshold) {
                refreshData()
                displayedElevation = _baseElevation
            }
        }
    }
 
    /*Change in Altitude to cause overlay refresh : Meters */
    private var _baseElevationChangeThreshold: CLLocationDistance = 0
    var baseElevationChangeThreshold: CLLocationDistance {
        get {
            return _baseElevationChangeThreshold
        }
        set(baseElevationChangeThreshold) {
            _baseElevationChangeThreshold = baseElevationChangeThreshold
    
            if abs(Float(baseElevation - displayedElevation)) > Float(_baseElevationChangeThreshold) {
                refreshData()
            }
        }
    }
    
    
    /*Displayed Altitude (subject to threshold) : Meters */
    var displayedElevation: CLLocationDistance = 0
    
    
    /*Max Altitude : Meters (Relative to Base) */
    private var _maxElevation: CLLocationDistance = 0
    var maxElevation: CLLocationDistance {
        get {
            return _maxElevation
        }
        set(maxElevation) {
            if _maxElevation != maxElevation {
                _maxElevation = maxElevation
                refreshData()
            }
        }
    }
    
    private var _alpha: Int = 0  /*0..255 */
    var alpha: Int {
        get {
            return _alpha
        }
        set(alpha) {
            if _alpha != alpha {
                _alpha = alpha
                refreshData()
            }
        }
    }
    
    private var _colors: Int = 0
    var colors: Int {
        get {
            return _colors
        }
        set(colors) {
            if _colors != colors {
                _colors = colors
                refreshData()
            }
        }
    }
    
    
    var displayMercatorGrid: Bool = false {
        didSet {refreshData()}
    }
    
    var displayMercatorLabel : Bool = false {
        didSet { refreshData()}
    }
    
    
    var displayMapRectLabel : Bool = false {
        didSet { refreshData()}
    }
    
    var displayLocationLabel : Bool = false {
        didSet { refreshData()}
    }
    
    var displayMapPointLabel: Bool = false {
        didSet { refreshData()}
    }
    
    var displayGridSizeLabel: Bool = false {
        didSet { refreshData()}
    }
    
    var lidarTileCacheArray: [LidarTileOverlayCacheElement] = []
    var lidarTileCacheArrayLock: NSLock?
    var lidarTileCacheSize: Int = 0
    
    var mapCache : MapCache = MapCache()
    //****************************************************************************************************************************************

    
    override init(urlTemplate URLTemplate: String?) {
        super.init(urlTemplate: URLTemplate)

        baseElevation = CLLocationDistance(0)
        maxElevation = CLLocationDistance(1000)
        alpha = 200
        colors = 10
        baseElevationChangeThreshold = feetToMeters(10)
        displayedElevation = CLLocationDistance(0)

        #if os(iOS)
                lidarTileCacheSize = 5000
        #elseif os(OSX)
                lidarTileCacheSize = 1000
        #elseif os(tvOS)
        #elseif os(watchOS)
        #endif

        //lidarTileCacheArray = [LidarTileOverlayCacheElement]()
        //lidarTileCacheArray.reserveCapacity(lidarTileCacheSize)
        //lidarTileCacheArrayLock = NSLock()
        
        
    }

    //****************************************************************************************************************************************

    func refreshData() {
        if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)]  displayedElevation:%0.1f baseElevation:%0.1f baseThreshold:%0.1f",displayedElevation, baseElevation, baseElevationChangeThreshold))  }

        tileOverlayRenderer?.reloadData()
    }

    func lidarTile(for path: MKTileOverlayPath) -> LidarTileOverlayCacheElement? {
        if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)]  displayedElevation:%0.1f baseElevation:%0.1f baseThreshold:%0.1f",displayedElevation, baseElevation, baseElevationChangeThreshold))  }

        var lidarTileOverlayCacheElement: LidarTileOverlayCacheElement?

        lidarTileCacheArrayLock?.lock()
        //for i in (0..<lidarTileCacheArray.count).reversed() {
        for i in 0..<lidarTileCacheArray.count {
            let tempLidarTileCacheElement = lidarTileCacheArray[i]

            if (path.x == tempLidarTileCacheElement.path?.x) && (path.y == tempLidarTileCacheElement.path?.y) && (path.z == tempLidarTileCacheElement.path?.z) {
                tempLidarTileCacheElement.hitCount = tempLidarTileCacheElement.hitCount + 1

                lidarTileOverlayCacheElement = tempLidarTileCacheElement
                break
            }
        }
        lidarTileCacheArrayLock?.unlock()
        return lidarTileOverlayCacheElement
    }
    

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        //let lidarTileOverlayCacheElement: LidarTileOverlayCacheElement? = lidarTile(for: path)

        if (debug) { print(String(format:"\(timestamp) \(#function) [\(#line)]  Load z:%i x:%i y:%i  cacheZ:%i ", path.z, path.x, path.y, mapCache.cacheZ)) }

        mapCache.setCacheZ(z: path.z)
        
        let data = mapCache.get(tilePath: path)
        
        if data != nil {
            /*
            if (debug) { print(String(format:"\(timestamp) \(#function) [\(#line)]  Cache z:%i x:%i y:%i Size=%i hitCount=%i",
                lidarTileOverlayCacheElement!.path!.z, lidarTileOverlayCacheElement!.path!.x, lidarTileOverlayCacheElement!.path!.y, lidarTileOverlayCacheElement!.lidarTileData!.count, lidarTileOverlayCacheElement!.hitCount)) }
            */

            #if os(iOS)
            
                if perfTest {

                    result(perfImg,nil)
                }
                result(self.lidarTile(at: path, forTileData: data),nil)
            
            #elseif os(OSX)
                //TBD
                result(image?.tiffRepresentation, nil)
            #endif
        } else {

            super.loadTile(at: path, result: {tileData, error in

                if error != nil {
                    if (self.debug) {print(String(format:"\(timestamp) \(#function) [\(#line)]  : %@","Error"))}
                    result(nil, error)

                } else if (tileData?.count ?? 0) != 256 * 256 * 2 {
                    let tileSizeRatio : Float = Float(tileData?.count ?? 0)/Float(256 * 256 * 2) * 100.0
                    print(String(format:"\(timestamp) \(#function) [\(#line)]  LoadTileSizeError Size:%lu Ratio: %0.1f",UInt(tileData?.count ?? 0),tileSizeRatio))
                    result(tileData,error)
                    
                } else {
                    //if (self.debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] : %i",tileData?.count ?? 0))  }

                    let lidarTileOverlayCacheElement = LidarTileOverlayCacheElement()
                    lidarTileOverlayCacheElement.path = path
                    lidarTileOverlayCacheElement.hitCount = 1
                    lidarTileOverlayCacheElement.lidarTileData = tileData
                    
                    self.mapCache.add(tilePath: path, data: tileData)
/*
                    self.lidarTileCacheArrayLock?.lock()
                    self.lidarTileCacheArray.append(lidarTileOverlayCacheElement)
                    if self.lidarTileCacheArray.count > self.lidarTileCacheSize {
                        self.lidarTileCacheArray.remove(at: 0)
                    }
                    self.lidarTileCacheArrayLock?.unlock()
 */
                    
                    if (false) { print(String(format:"\(timestamp) \(#function) [\(#line)]  Loaded z:%i x:%i y:%i Size=%i hitCount=%i",
                        lidarTileOverlayCacheElement.path!.z, lidarTileOverlayCacheElement.path!.x, lidarTileOverlayCacheElement.path!.y, lidarTileOverlayCacheElement.lidarTileData!.count, lidarTileOverlayCacheElement.hitCount)) }
                    
                    result(self.lidarTile(at: path, forTileData: tileData),nil)
                }
                
                

                #if os(OSX)
                    if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)] XXXXXX displayedElevation:%0.1f baseElevation:%0.1f baseThreshold:%0.1f",displayedElevation, baseElevation, baseElevationChangeThreshold))  }

                    if let image = tileData?.lidarImage(gridWidth: 256, gridHeight: 256,
                                                 baseValue: Int(metersToFeet(self.baseElevation)),
                                                maxValue: Int(metersToFeet(self.maxElevation)),
                                                 alpha: self.alpha, colors: self.colors) {
                        let data = image.pngData() as NSData?
                        result(data! as Data,nil)
                    } else {
                        result(nil,nil)
                    }

                #elseif os(OSX)
                    //TBD
                    result(image?.tiffRepresentation, nil)
                #endif
            })
        }
    }




    
    
#if os(iOS)
    func lidarTile(at path: MKTileOverlayPath, forTileData tileData: Data?) -> Data? {
        //if (debug) {print(String(format: "Loading tile z/x/y: %ld/%ld/%ld", path.z, path.x, path.y))}
        
        if let tileImage = tileData?.lidarImage(gridWidth: 256, gridHeight: 256,
                                         baseValue: Int(metersToFeet(self.baseElevation)),
                                         maxValue: Int(metersToFeet(self.maxElevation)),
                                         alpha: self.alpha, colors: self.colors) {
            
            if displayMercatorGrid == false  {
                return tileImage.pngData()
            
            } else {
                let tileMapRect: MKMapRect = MKMapRect(forTilePath: path)
                let tileRegion: MKCoordinateRegion = MKCoordinateRegion(tileMapRect)
                
                var text = ""
                if displayMercatorLabel {
                    text = text + (String(format: "Z:%ld X:%ld Y:%ld\n", path.z, path.x, path.y))
                }
                
                if displayLocationLabel {
                    text = text + (String(format: "Loc:%0.4f,%0.4f\n", tileRegion.center.latitude, tileRegion.center.longitude))
                }
                
                if displayMapRectLabel {
                    text = text + (String(format: "OriginX:%0.0f\nOriginY:%0.0f\n", tileMapRect.origin.x, tileMapRect.origin.y))
                }

                if displayMapPointLabel {
                    let mapPoint: MKMapPoint = MKMapPoint(tileRegion.center)
                    text = text + (String(format: "CenterX:%ld CenterY:%ld\n", Int(mapPoint.x), Int(mapPoint.y)))
                }
                
                if displayGridSizeLabel || displayMercatorLabel {
                    let mappointXMin : MKMapPoint = MKMapPoint.init(x: tileMapRect.minX, y: tileMapRect.midY)
                    let mappointXMax : MKMapPoint = MKMapPoint.init(x: tileMapRect.maxX, y: tileMapRect.midY)
                    let xWidth =  mappointXMin.distance(to: mappointXMax)
                    
                    //let mappointYMin : MKMapPoint = MKMapPoint.init(x: tileMapRect.midX, y: tileMapRect.minY)
                    //let mappointYMax : MKMapPoint = MKMapPoint.init(x: tileMapRect.midX, y: tileMapRect.maxY)
                    //let yWidth = mappointYMin.distance(to: mappointYMax)
                    
                    
                    text = text + (String(format: "RectSize:%@\n", xWidth.imperialDistanceString()))
                    text = text + (String(format: "PixelSize:%@\n", (xWidth/256).imperialDistanceString()))
                }
                
                let sz: CGSize = tileSize
                let rect = CGRect(x: 0, y: 0, width: sz.width, height: sz.height)
                
                UIGraphicsBeginImageContext(sz)
                let ctx = UIGraphicsGetCurrentContext()
                
                //CGContextDrawImage(ctx, rect, tileImage.CGImage);
                //CGContextDrawImage(ctx, rect, tileImage.CGImage);
                tileImage.draw(in: rect)
                
                UIColor.black.setStroke()
                ctx?.setLineWidth(2.0)
                ctx?.stroke(CGRect(x: 0, y: 0, width: sz.width, height: sz.height))

                text.draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24.0), NSAttributedString.Key.foregroundColor: UIColor.blue])

                let newtileImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                if perfImg == nil {
                    if path.z == 8 && path.x == 73 && path.y == 98 {
                        perfImg = newtileImage!.pngData()
                    }
                }
                
                return newtileImage!.pngData()
            }
        }
        
        return nil
        
    }
    
#elseif os(OSX)
    func lidarTile(at path: MKTileOverlayPath, forGrid grid: UnsafeMutablePointer<Int16>?) -> Data? {
        print(String(format: "Loading tile z/x/y: %ld/%ld/%ld", path.z, path.x, path.y))

        let tileImage: UIImage? = LidarTileManager.lidarImage(forGrid: grid, gridWidth: 256, gridHeight: 256, baseValue: metersToFeet(baseElevation), maxValue: metersToFeet(maxElevation), alpha: alpha, colors: colors)
/*
        if displayMercatorGrid {
            let tileMapRect: MKMapRect = MKUtilities.mapRect(forTilePath: path)

            let tileRegion: MKCoordinateRegion = MKCoordinateRegionForMapRect(tileMapRect)

            var text = ""

            if displayLocationLabel {
                text = text + (String(format: "Loc:%0.4f,%0.4f\n", tileRegion.center.latitude, tileRegion.center.longitude))
            }
            if displayMapRectLabel {
                text = text + (String(format: "MapRectX:%0.0f\nMapRectY:%0.0f\n", tileMapRect.origin.x, tileMapRect.origin.y))
            }
            if displayMercatorLabel {
                text = text + (String(format: "Z:%ld X:%ld Y:%ld\n", path.z, path.x, path.y))
            }
            if displayMapPointLabel {
                let mapPoint: MKMapPoint = MKMapPointForCoordinate(tileRegion.center)
                text = text + (String(format: "X:%ld Y:%ld\n", Int(mapPoint.x), Int(mapPoint.y)))
            }

            let sz: CGSize = tileSize
            let rect = CGRect(x: 0, y: 0, width: sz.width, height: sz.height)

            UIGraphicsBeginImageContext(sz)
            let ctx = UIGraphicsGetCurrentContext()

            //CGContextDrawImage(ctx, rect, tileImage.CGImage);
            //CGContextDrawImage(ctx, rect, tileImage.CGImage);
            tileImage?.draw(in: rect)

            UIColor.black.setStroke()
            ctx?.setLineWidth(2.0)
            ctx?.stroke(CGRect(x: 0, y: 0, width: sz.width, height: sz.height))
            //NSString *text = [NSString stringWithFormat:@"Z=%ld\nX=%ld\nY=%ld",(long)path.z,(long)path.x,(long)path.y];
            //NSString *text = [NSString stringWithFormat:@"Z:%ld X:%ld Y:%ld",(long)path.z,(long)path.x,(long)path.y];
            text.draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24.0), NSAttributedString.Key.foregroundColor: UIColor.blue])
            //UIImage *newTileImage = UIGraphicsGetImageFromCurrentImageContext();
            let newtileImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImagePNGRepresentation(newtileImage)
        }
 */

        return UIImagePNGRepresentation(tileImage)
        
    }

#endif
    
}





// MARK: - Elevation Tile Manager
class MapCache {
    
    var debug = true
    
    var cacheLevels = [6,9,12,14]
    var cachedMapRects = [MKMapRect.init(coordinates: [CLLocationCoordinate2DMake(49.00459, -126.32472), CLLocationCoordinate2DMake(23.71784, -66.94475)])]
    
    var cacheDictionary = Dictionary<UInt64, Data>()
    
    
    var cacheCount : Int  {
        get {
            return cacheDictionary.count
        }
    }
    
    var cacheSize : Int {
        get {
            return cacheDictionary.count * 256 * 256 * 4
        }
    }

    func clearCache () {
        if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)] - ClearCache:  %@",description()))  }
        cacheDictionary.removeAll()
    }
    
    var cacheZ : Int = 0
    var cacheCountTotal : Int = 0
    
    var cacheSizeTotal : Int {
        get {
            return cacheCountTotal * 256 * 256 * 4
        }
    }
    
    func setCacheZ(z:Int) {
        if cacheZ != z {
            cacheZ = z
            clearCache()
        }
    }
    
    
    func cacheURL(tilePath:MKTileOverlayPath) -> URL? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let file = String(format:"lidar/%i/%i/%i.ldr",tilePath.z,tilePath.x,tilePath.y)
            let fileURL = dir.appendingPathComponent(file)
            return fileURL
            
        }
        return nil
    }
    
    func cacheMKTileOverlayPath( for tilePath:MKTileOverlayPath) -> MKTileOverlayPath? {
        
        let cacheMKTileOverlayPath = MKTileOverlayPath.init(x: tilePath.x, y: tilePath.y, z: tilePath.z, contentScaleFactor: 1.0)
        return cacheMKTileOverlayPath
    }

    func add(tilePath:MKTileOverlayPath,data:Data?) {
        if let data = data  {
            if let cacheURL = cacheURL(tilePath: tilePath) {
                do{
                    try FileManager.default.createDirectory(at: cacheURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)

                    do {
                        if (false && debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] - Count %i",data.count))  }
                        if data.count == 0 {
                            let tempData = Data([0xFF])
                            try tempData.write(to: cacheURL)
                            if (debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] - %i/%i/%i.ldr : Write Null Success",tilePath.z,tilePath.x,tilePath.y))  }
                        } else {
                            try data.write(to: cacheURL)
                            if (debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] - %i/%i/%i.ldr : Write Success",tilePath.z,tilePath.x,tilePath.y))  }
                        }
                        if (debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] - %i/%i/%i.ldr : Write Success",tilePath.z,tilePath.x,tilePath.y))  }
                    } catch {
                        if (debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] - %i/%i/%i.ldr : Write Error",tilePath.z,tilePath.x,tilePath.y))  }
                    }
                    
                } catch let error as NSError{
                    if (debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] - %i/%i/%i.ldr : Unable To Create Directory",tilePath.z,tilePath.x,tilePath.y))  }
                    print("Unable to create directory",error)
                }
            }
        }
    }

    
    //*********************************** New  ***********************
    func cacheZLevel(for tilePath:MKTileOverlayPath) -> Int? {
        var cacheZLevel : Int?
        
        for zLevel in cacheLevels {
            if tilePath.z >= zLevel {
                cacheZLevel = zLevel
            } else {
                break
            }
        }
        return cacheZLevel
    }
    
    func cacheMKOverlayPath(for tilePath:MKTileOverlayPath) -> MKTileOverlayPath? {
        var cacheZLevel : Int?
        //var cacheMKTileOverlayPath : MKTileOverlayPath?
        
        for zLevel in cacheLevels {
            if tilePath.z >= zLevel {
                cacheZLevel = zLevel
            } else {
                break
            }
        }
        
        if let cacheZLevel = cacheZLevel  {
            let zoomScale = tilePath.z - cacheZLevel
    
            let pixelScale = Int(pow(2.0,Double(zoomScale)))
            let newX = tilePath.x/pixelScale
            let newY = tilePath.y/pixelScale
            
            let cacheMKTileOverlayPath = MKTileOverlayPath.init(x: newX , y: newY, z: cacheZLevel, contentScaleFactor: tilePath.contentScaleFactor)
            return cacheMKTileOverlayPath
        }
        
        return nil
    }
    
    func get(tilePath:MKTileOverlayPath, fromZoomLevel : Int) -> Data? {
        
        let cachedMKOverlayPath = cacheMKOverlayPath(for: tilePath)
        
        
        if let cacheURL = cacheURL(tilePath: tilePath) {
            do {
                let data = try Data(contentsOf: cacheURL)
                if (false && debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] - %i/%i/%i.ldr : Read Success",tilePath.z,tilePath.x,tilePath.y))  }
                return data
            } catch {
                if (debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] - %i/%i/%i.ldr : Read Miss/Error",tilePath.z,tilePath.x,tilePath.y))  }
                return nil
            }
        }
        return nil
    }
    
    
    
    func get(tilePath:MKTileOverlayPath) -> Data? {
        
        let cachedMKOverlayPath = cacheMKOverlayPath(for: tilePath)
        
        if let cacheURL = cacheURL(tilePath: tilePath) {
            do {
                let data = try Data(contentsOf: cacheURL)
                if (false && debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] - %i/%i/%i.ldr : Read Success",tilePath.z,tilePath.x,tilePath.y))  }
                return data
            } catch {
                if (debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] - %i/%i/%i.ldr : Read Miss/Error",tilePath.z,tilePath.x,tilePath.y))  }
                return nil
            }
        }
        return nil
    }
    
    func addOld(tilePath:MKTileOverlayPath,data:Data?) {
        if let data = data  {
            let pathID  = tilePath.pathID()
            
            if cacheZ != tilePath.z {
                cacheDictionary[pathID] = data
            }
            
            cacheCountTotal += 1
        }
    }
    
    func getOld(tilePath:MKTileOverlayPath) -> Data? {

        let pathID  = tilePath.pathID()
        let data = cacheDictionary[pathID]
        if data == nil {
            if (debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] - Hit: tileZ:%i %@",tilePath.z,description()))  }
        } else {
            if (debug) { print(String(format:"\(timestamp) \(#function) [\(#line)] - Hit: tileZ:%i %@",tilePath.z,description()))  }
        }
        
        return data
    }
    
    func description () -> String {
        let tempString = String(format: "z:%i, Current:%i,%0.1fMB  Total:%i,%0.1fMB", cacheZ,
                                cacheCount,Float(cacheSize)/1048576.0,
                                cacheCountTotal,Float(cacheSizeTotal)/1048576.0)
        return tempString
    }
}


class LidarTileOverlayCacheElement {
    var path                : MKTileOverlayPath?
    var hitCount            : Int = 0
    var lidarTileData       : Data?
}

extension Data {
    func lidarImageX( gridWidth: Int, gridHeight: Int, baseValue: Int, maxValue: Int, alpha: Int, colors: Int) -> UIImage?{
        if (false) { print(String(format:"\(timestamp) \(#function) [\(#line)] : %@","*"))  }
        
        if self.count != gridWidth*gridHeight*2 {
            return nil
        }
        var finalImage : UIImage? = nil
        
        self.withUnsafeBytes {  (grid: UnsafePointer<UInt16>) in
            let outputWidth: Int = gridWidth
            let outputHeight: Int = gridHeight
            
            // Setup Graphics Context
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let bytesPerPixel: Int = 4
            let bitsPerComponent: Int = 8
            
            //let outputPixels = calloc(outputHeight * outputWidth, MemoryLayout<UInt32>.size)
            
            var outputPixelArray : [UInt32] = []
            outputPixelArray.reserveCapacity(outputHeight * outputWidth)
            
            let outputBytesPerRow: Int = bytesPerPixel * outputWidth
            
            let context = CGContext(data: &outputPixelArray, width: outputWidth, height: outputHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: outputBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            
            if (false) { print(String(format:"\(timestamp) \(#function) [\(#line)] : [%i,%i] = %i",0,0,grid[0]))  }
            
            var color : UInt32 = 0
            //Create Graphics image
            for i in 0..<outputHeight {
                for j in 0..<outputWidth {
                    color = 0
                    
                    let elevation : Int = Int(grid[i * outputWidth + j])
                    let deltaElevation = elevation - baseValue
                    
                    if (deltaElevation > 0) {
                        let floatColor = Float(deltaElevation)/Float(maxValue)
                        
                        color = DEColor.rgba3ColorGradient(from: floatColor, alpha: alpha, colors: colors)
                        //color = RGMAMake(r: i, g: j, b: 0, a: 128)
                    }
                    
                    outputPixelArray.append(color)
                    //if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)] : [%i,%i] = %i",i,j,value))  }
                }
            }
            
            let imageRef = context!.makeImage()
            finalImage = UIImage(cgImage: imageRef!)
            
            //free(outputPixels)
            //CGContextRelease(context)
        }
        
        
        return finalImage
    }
    
    func lidarImage( gridWidth: Int, gridHeight: Int, baseValue: Int, maxValue: Int, alpha: Int, colors: Int) -> UIImage?{
        if (false) { print(String(format:"\(timestamp) \(#function) [\(#line)] : %@","*"))  }
        
        if self.count != gridWidth*gridHeight*2 {
            return nil
        }
        var finalImage : UIImage? = nil
        
        self.withUnsafeBytes {  (grid: UnsafePointer<UInt16>) in
            let outputWidth: Int = gridWidth
            let outputHeight: Int = gridHeight
            
            // Setup Graphics Context
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let bytesPerPixel: Int = 4
            let bitsPerComponent: Int = 8
            
            let outputBytesPerRow: Int = bytesPerPixel * outputWidth
            
            let context = CGContext(data: nil, width: outputWidth, height: outputHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: outputBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            
            if (false) { print(String(format:"\(timestamp) \(#function) [\(#line)] : [%i,%i] = %i",0,0,grid[0]))  }
            
            var dataPointer = context?.data     //UnsafeMutableRawPointer?
            
            var color : UInt32 = 0
            //Create Graphics image
            for i in 0..<outputHeight {
                for j in 0..<outputWidth {
                    color = 0
                    
                    let elevation : Int = Int(grid[i * outputWidth + j])
                    let deltaElevation = elevation - baseValue
                    
                    if (deltaElevation > 0) {
                        let floatColor = Float(deltaElevation)/Float(maxValue)
                        
                        color = DEColor.rgba3ColorGradient(from: floatColor, alpha: alpha, colors: colors)
                        //color = DEColor.RGBAMake(r: i, g: j, b: 0, a: 128)
                    }
                    
                    dataPointer?.storeBytes(of: color, as: UInt32.self)
                    dataPointer = dataPointer! + 4
                    //outputPixelArray.append(color)
                    //if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)] : [%i,%i] = %i",i,j,value))  }
                }
            }
            
            let imageRef = context!.makeImage()
            finalImage = UIImage(cgImage: imageRef!)
            
            //free(outputPixels)
            //CGContextRelease(context)
        }
        
        
        return finalImage
    }
    
}
