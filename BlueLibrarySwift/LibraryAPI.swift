//
//  LibraryAPI.swift
//  BlueLibrarySwift
//
//  Created by jos on 11/28/16.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import UIKit

class LibraryAPI: NSObject {
    
    private let persistencyManager: PersistencyManager
    private let httpClient: HTTPClient
    private let isOnline: Bool
    
    // Singleton Declaration
    class var sharedInstance: LibraryAPI {
        //1
        struct Singleton {
            static let instance = LibraryAPI()
        }
        return Singleton.instance
    }

    override init() {
        persistencyManager = PersistencyManager()
        httpClient = HTTPClient()
        isOnline = false
        
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImage(notification:)), name: NSNotification.Name(rawValue: "BLDownloadImageNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getAlbums() -> [Album] {
        return persistencyManager.getAlbums()
    }
    
    func addAlbum(album: Album, index: Int) {
        persistencyManager.addAlbum(album: album, index: index)
        if isOnline {
           //httpClient.postRequest("/api/addAlbum", body: album.description)
            
        }
    }
    
    func deleteAlbum(index: Int) {
        persistencyManager.deleteAlbum(index: index)
        if isOnline {
            //httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
        }
    }
    
    func downloadImage(notification: NSNotification) {
        //1
        let userInfo = notification.userInfo as! [String: AnyObject]
        let imageView = userInfo["imageView"] as! UIImageView?
        let coverUrl = userInfo["coverUrl"] as! String
        
        //2
        if let imageViewUnWrapped = imageView {
            imageViewUnWrapped.image = persistencyManager.getImage(filename: coverUrl)
            if imageViewUnWrapped.image == nil {
                //3
                DispatchQueue.global().async(execute: { () -> Void in
                    let downloadedImage = self.httpClient.downloadImage(coverUrl as String)
                    //4
                    DispatchQueue.main.sync(execute: { () -> Void in
                        imageViewUnWrapped.image = downloadedImage
                        self.persistencyManager.saveImage(image: downloadedImage, filename: coverUrl)
                    })
                })
            }
        }
    }
    
    // part of Memento - save album data
    func saveAlbums() {
        persistencyManager.saveAlbums()
    }
    
    
}


/*
 1.- Singleton wraps a static constant variable named instance. Declaring a property as static means this property only exists once. Also note that static properties in Swift are implicitly lazy, which means that Instance is not created until it’s needed. Also note that since this is a constant property, once this instance is created, it’s not going to create it a second time. This is the essence of the Singleton design pattern. The initializer is never called again once it has been instantiated.
 */
