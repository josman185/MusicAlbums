//
//  AlbumExtensions.swift
//  BlueLibrarySwift
//
//  Created by jos on 11/29/16.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import Foundation

extension Album {
    func ae_tableRepresentation() -> (titles:[String], values:[String]) {
        return (["Artist", "Album", "Genre", "Year"], [artist, title, genre, year])
    }
}
