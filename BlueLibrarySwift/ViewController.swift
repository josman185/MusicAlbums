/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class ViewController: UIViewController {

	@IBOutlet var dataTable: UITableView!
	@IBOutlet var toolbar: UIToolbar!
    @IBOutlet weak var scroller: HorizontalScroller!
    
    // the next 3 variables were Private at the begining
    fileprivate var allAlbums = [Album]()
    fileprivate var currentAlbumData : (titles:[String], values:[String])?
    fileprivate var currentAlbumIndex = 0
    
    // We will use this array as a stack to push and pop operation for the undo option
    var undoStack: [(Album, Int)] = []
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        //1
        self.navigationController?.navigationBar.isTranslucent = false
        currentAlbumIndex = 0
        
        //2
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        
        // 3
        // the uitableview that presents the album data
        dataTable.delegate = self
        dataTable.dataSource = self
        dataTable.backgroundView = nil
        view.addSubview(dataTable!)
        
        self.showDataForAlbum(albumIndex: currentAlbumIndex)
        
        //MEMENTO Design Pattern method
        loadPreviousState()
        
        scroller.delegate = self
        reloadScroller()
        
        // tool bar, undo and delete button
        let undoButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action:#selector(ViewController.undoAction))
        undoButton.isEnabled = false;
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target:nil, action:nil)
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target:self, action:#selector(ViewController.deleteAlbum))
        let toolbarButtonItems = [undoButton, space, trashButton]
        toolbar.setItems(toolbarButtonItems, animated: true)
        
        // send notification when the app enters the background in order to save current state of the app
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.saveCurrentState), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    // you’ll need to un-register (always) for notifications
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // center the scroller image in the last viewd album
    func initialViewIndex(scroller: HorizontalScroller) -> Int {
        return currentAlbumIndex
    }
    
    func showDataForAlbum(albumIndex: Int) {
        // defensive code: make sure the requested index is lower than the amount of albums
        if (albumIndex < allAlbums.count && albumIndex > -1) {
            //fetch the album
            let album = allAlbums[albumIndex]
            // save the albums data to present it later in the tableview
            currentAlbumData = album.ae_tableRepresentation()
        } else {
            currentAlbumData = nil
        }
        // we have the data we need, let's refresh our tableview
        dataTable!.reloadData()
    }
    
    func reloadScroller() {
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        if currentAlbumIndex < 0 {
            currentAlbumIndex = 0
        } else if currentAlbumIndex >= allAlbums.count {
            currentAlbumIndex = allAlbums.count - 1
        }
        scroller.reload()
        showDataForAlbum(albumIndex: currentAlbumIndex)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Undo and delete Methods
    
    func addAlbumAtIndex(album: Album,index: Int) {
        LibraryAPI.sharedInstance.addAlbum(album: album, index: index)
        currentAlbumIndex = index
        reloadScroller()
    }
    
    func deleteAlbum() {
        //1. get the album to delete
        let deletedAlbum : Album = allAlbums[currentAlbumIndex]
        //2. create a Tuple wich stores the album and the index of the album
        let undoAction = (deletedAlbum, currentAlbumIndex)
        undoStack.insert(undoAction, at: 0)
        //3. Use LibraryAPI to delete the album from the data structure and reload the scroller
        LibraryAPI.sharedInstance.deleteAlbum(index: currentAlbumIndex)
        reloadScroller()
        //4. Since there’s an action in the undo stack, you need to enable the undo button.
        let barButtonItems = toolbar.items! as [UIBarButtonItem]
        let undoButton : UIBarButtonItem = barButtonItems[0]
        undoButton.isEnabled = true
        //5
        if (allAlbums.count == 0) {
            let trashButton : UIBarButtonItem = barButtonItems[2]
            trashButton.isEnabled = false
        }
    }
    
    func undoAction() {
        let barButtonItems = toolbar.items! as [UIBarButtonItem]
        //1
        if undoStack.count > 0 {
            let (deletedAlbum, index) = undoStack.remove(at: 0)
            addAlbumAtIndex(album: deletedAlbum, index: index)
        }
        //2
        if undoStack.count == 0 {
            let undoButton : UIBarButtonItem = barButtonItems[0]
            undoButton.isEnabled = false
        }
        //3
        let trashButton : UIBarButtonItem = barButtonItems[2]
        trashButton.isEnabled = true
    }
    
    //MARK: Memento Pattern
    func saveCurrentState() {
        // When the user leaves the app and then comes back again, he wants it to be in the exact same state
        // he left it. In order to do this we need to save the currently displayed album.
        // Since it's only one piece of information we can use NSUserDefaults.
        
        UserDefaults.standard.set(currentAlbumIndex, forKey: "currentAlbumIndex")
        
        // part of Memento
        LibraryAPI.sharedInstance.saveAlbums()
    }
    
    func loadPreviousState() {
        currentAlbumIndex = UserDefaults.standard.integer(forKey: "currentAlbumIndex")
        showDataForAlbum(albumIndex: currentAlbumIndex)
    }


}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let albumData = currentAlbumData {
            return albumData.titles.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) 
        if let albumData = currentAlbumData {
            cell.textLabel!.text = albumData.titles[indexPath.row]
            cell.detailTextLabel!.text = albumData.values[indexPath.row]
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
}

extension ViewController: HorizontalScrollerDelegate {
    
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index: Int) {
        //1
        let previousAlbumView = scroller.viewAtIndex(index: currentAlbumIndex) as! AlbumView
        previousAlbumView.highlightAlbum(didHighLightView: false)
        //2
        currentAlbumIndex = index
        //3
        let albumView = scroller.viewAtIndex(index: index) as! AlbumView
        albumView.highlightAlbum(didHighLightView: true)
        //4
        showDataForAlbum(albumIndex: index)
    }
    
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> (Int) {
        return allAlbums.count
    }
    
    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index: Int) -> (UIView) {
        let album = allAlbums[index]
        let albumView = AlbumView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), albumCover: album.coverUrl)
        if currentAlbumIndex == index {
            albumView.highlightAlbum(didHighLightView: true)
        } else {
            albumView.highlightAlbum(didHighLightView: false)
        }
        return albumView
    }
    
}

