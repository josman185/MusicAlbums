//
//  AlbumView.swift
//  BlueLibrarySwift
//
//  Created by jos on 11/28/16.
//  Copyright © 2016 Raywenderlich. All rights reserved.
//

import UIKit

class AlbumView: UIView {

    private var coverImage: UIImageView!
    private var indicator: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init(frame: CGRect, albumCover: String) {
        super.init(frame: frame)
        commonInit()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BLDownloadImageNotification"), object: self, userInfo: ["imageView": coverImage, "coverUrl": albumCover])
        
        
    }
    
    func commonInit() {
        backgroundColor = UIColor.black
        coverImage = UIImageView(frame: CGRect(x: 5, y: 5, width: frame.size.width - 10, height: frame.size.height - 10))
        addSubview(coverImage)
        // add KVO
        coverImage.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions(), context: nil)
        indicator = UIActivityIndicatorView()
        indicator.center = center
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.startAnimating()
        addSubview(indicator)
    }
    
    func highlightAlbum(didHighLightView: Bool) {
        if didHighLightView == true {
            backgroundColor = UIColor.white
        }else {
            backgroundColor = UIColor.black
        }
    }
    
    deinit {
        coverImage.removeObserver(self, forKeyPath: "image")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "image" {
            indicator.stopAnimating()
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
