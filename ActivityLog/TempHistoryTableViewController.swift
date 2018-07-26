//
//  TempHistoryTableViewController.swift
//  ActivityLog
//
//  Created by Ziqi Li on 7/25/18.
//  Copyright © 2018 Ziqi Li. All rights reserved.
//

import UIKit
import TimelineTableViewCell
import ChameleonFramework
import SCLAlertView
import MessageUI
import Parse
import DZNEmptyDataSet
class TempHistoryTableViewController: UITableViewController,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var trackList:[Track] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = false
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    func reloadData(){
        self.trackList.removeAll()
        retriveDataFromParse()
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let labelText = "No Temperature Log Yet"
        let strokeTextAttributes = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18)
            ] as [NSAttributedStringKey : Any]
        
        return NSAttributedString(string: labelText, attributes: strokeTextAttributes)
    }
    
    //Get data from MongoDB
    func retriveDataFromParse(){
        let query = PFQuery(className:"Tracks")
        //query.limit = 500
        query.fromLocalDatastore()
        query.addDescendingOrder("createdAt")
        //query.whereKey("user", equalTo:PFUser.current()?.username)
        //query.whereKey("user", equalTo: "CDus8o97S")
        
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                let number = objects?.count as! Int
                for i in 0 ..< number {
                    let curLog = objects?[i]
                    let timeString = curLog?["loctime"] as! String
                    /*
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd HH:mm"
                    let timeString = formatter.string(from: time)
                    formatter.dateFormat = "yyyy/MM/dd HH:mm"
                    */
                    var temp = -100.0
                    if curLog?["temp"] != nil {
                        temp = curLog?["temp"] as! Double
                    }
                    let track = Track(temp: temp, time: timeString, lat: CLLocationDegrees(0), lon: CLLocationDegrees(0))
                    self.trackList.append(track)
                }
                self.tableView.reloadData()
                
            }
            
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trackList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bundle = Bundle(for: TimelineTableViewCell.self)
        let nibUrl = bundle.url(forResource: "TimelineTableViewCell", withExtension: "bundle")
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell",
                                             bundle: Bundle(url: nibUrl!)!)
        tableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell",
                                                 for: indexPath) as! TimelineTableViewCell
        
        let track = self.trackList[indexPath.row]
        configureCell(cell, withTrack: track, at: indexPath)
        return cell
        
    }
    
    func configureCell(_ cell: TimelineTableViewCell, withTrack track: Track, at ip: IndexPath) {

        let title = track.temp!
        let time = track.time!
        
        cell.timelinePoint = TimelinePoint()
        if ip.row == 0{
            cell.timeline.frontColor = UIColor.clear
        } else {
            cell.timeline.frontColor = UIColor.flatMint
        }
        
        cell.timeline.backColor = UIColor.flatMint
        
        
        if (title <= -90){
            cell.titleLabel.text = "N/A"
            cell.bubbleColor = UIColor.flatGray
        }
        else if (title >= 90.0){
            cell.bubbleColor = UIColor.flatRed
            cell.titleLabel.text = String(format: "%.1f", title) + "°F"
        }
        else {
            cell.bubbleColor = UIColor.flatGreen
            cell.titleLabel.text = String(format: "%.1f", title) + "°F"
        }

        cell.descriptionLabel.text = time
        cell.lineInfoLabel.text = nil
        cell.thumbnailImageView.image = nil
        cell.illustrationImageView.image = nil
    }
    @IBAction func cancelBTN(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
