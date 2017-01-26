//
//  PersistencyManager.swift
//  BlueLibrarySwift
//
//  Created by jos on 11/28/16.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import UIKit

class PersistencyManager: NSObject {
    
    private var albums = [Album]()
    
    override init() {
        super.init()
        
        /* *** FILE MANAGER DOESN'T WORK IN THIS CASE  ***
        //let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //let path = documentsPath.appendingPathComponent("albums.bin")
        //let data = NSData(contentsOfFile: String(describing: path))
        */
        let data = try? Data(contentsOf: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/albums.bin"))
        if data != nil {
            let unarchivingAlbums = NSKeyedUnarchiver.unarchiveObject(with: data!) as! [Album]?
            if let unwrappedAlbum = unarchivingAlbums {
                albums = unwrappedAlbum
            }
        } else {
            self.createPlaceHolder()
        }
    }
    
        func createPlaceHolder() {
        //Dummy list of albums
        let album1 = Album(title: "Best of Bowie",
                           artist: "David Bowie",
                           genre: "Pop",
                           coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_david_bowie_best_of_bowie.png",
                           year: "1992")
        
        let album2 = Album(title: "It's My Life",
                           artist: "No Doubt",
                           genre: "Pop",
                           coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_no_doubt_its_my_life_bathwater.png",
                           year: "2003")
        
        let album3 = Album(title: "Nothing Like The Sun",
                           artist: "Sting",
                           genre: "Pop",
                           coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_sting_nothing_like_the_sun.png",
                           year: "1999")
        
        let album4 = Album(title: "Staring at the Sun",
                           artist: "U2",
                           genre: "Pop",
                           coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_u2_staring_at_the_sun.png",
                            year: "2000")
        
        let album5 = Album(title: "American Pie",
                           artist: "Madonna",
                           genre: "Pop",
                           coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_madonna_american_pie.png",
                            year: "2000")
        
        albums = [album1, album2, album3, album4, album5]
        
        // archiving method - Part of the NSCoding Protocol - Memento Design Patter
        saveAlbums()
        
    }
    
    func getAlbums() -> [Album] {
        return albums
    }
    
    func addAlbum(album: Album, index: Int) {
        if (albums.count >= index) {
            albums.insert(album, at: index)
        } else {
            albums.append(album)
        }
    }
    
    func deleteAlbum(index: Int) {
        albums.remove(at: index)
    }
    
    func saveImage(image: UIImage, filename: String) {

        //let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        //let path = documentsPath.appendingPathComponent(filename)

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let path = documentsPath.appendingPathComponent(filename)
        
        do {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error saving file at path: \(path) with error: \(error)")
        }
        
    /* // THIS WAS IMPLEMENTED IN THE TUTORIAL *** DOESN'T WORK***
        let path = NSHomeDirectory().appending("/Documents/\(filename)")
        let data = UIImagePNGRepresentation(image)
        //data.writeToFile(path, atomically: true)
        do {
            try data?.write(to: URL(fileURLWithPath: path))
        }
        catch {
            print("Error saving file at path: \(path) with error: \(error)")
        }
    */
    }
    
    func getImage(filename: String) -> UIImage? {
        /* THIS WAS IMPLEMENTED IN THE TUTORIAL *** DOESN'T WORK***
        //let error: NSError?
        //let path = NSHomeDirectory().appending("/Documents/\(filename)")
        //let data = NSData(contentsOfFile: path, options: .UncachedRead, error: &error)
        
        let data = NSData(contentsOfFile: path, options: .uncachedRead)
        if error != nil {
            return nil
        } else {
            return UIImage(data: data as Data)
        }
        */
        
        //let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        //let path = documentsPath.appendingPathComponent(filename)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let path = documentsPath.appendingPathComponent(filename)

        do {
            let data = try Data(contentsOf: path)
            return UIImage(data: data)
        }
        catch {
            print("Error getting the Image with Error: \(error)")
        }
        return nil
 
    }
    
    // Part of the NSCoding Protocol - Memento Design Patter
    func saveAlbums() {
        let filename = NSHomeDirectory().appending("/Documents/albums.bin")
        let data = NSKeyedArchiver.archivedData(withRootObject: albums)
        let _ = try? data.write(to: URL(fileURLWithPath: filename), options: [.atomic])
    }
}
