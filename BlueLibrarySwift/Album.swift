//
//  Album.swift
//  BlueLibrarySwift
//
//  Created by jos on 11/28/16.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import UIKit

class Album: NSObject, NSCoding {
    
    var title : String!
    var artist : String!
    var genre : String!
    var coverUrl : String!
    var year : String!
    
    init(title: String, artist: String, genre: String, coverUrl: String, year: String) {
        super.init()
        self.title = title
        self.artist = artist
        self.genre = genre
        self.coverUrl = coverUrl
        self.year = year
    }
    
    override var description: String {
        return "title: \(title)" +
            "artist: \(artist)" +
            "genre: \(genre)" +
            "coverUrl: \(coverUrl)" +
	       "year: \(year)"
    }
    
    // Archiving with NSCoding Protocol - Memento design Pattern
    
    required init(coder decoder: NSCoder) {
        super.init()
        self.title = decoder.decodeObject(forKey: "title") as! String
        self.artist = decoder.decodeObject(forKey: "artist") as! String
        self.genre = decoder.decodeObject(forKey: "genre") as! String
        self.coverUrl = decoder.decodeObject(forKey: "cover_url") as! String
        self.year = decoder.decodeObject(forKey: "year") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(artist, forKey: "artist")
        aCoder.encode(genre, forKey: "genre")
        aCoder.encode(coverUrl, forKey: "cover_url")
        aCoder.encode(year, forKey: "year")
    }

}
