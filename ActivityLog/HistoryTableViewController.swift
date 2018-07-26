//
//  HistoryTableViewController.swift
//  ActivityLog
//
//  Created by Ziqi Li on 5/15/18.
//  Copyright © 2018 Ziqi Li. All rights reserved.
//


import UIKit
import TimelineTableViewCell
import ChameleonFramework
import CoreData
import SCLAlertView
import MessageUI
import Parse

class HistoryTableViewController: UITableViewController {

    var managedObjectContext: NSManagedObjectContext? = nil
    var logList:[Log] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = false

    }
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    func reloadData(){
        self.logList.removeAll()
        print("reload:",self.logList.count)
        retriveDataFromParse()
    }
    
    //Get data from MongoDB
    func retriveDataFromParse(){
        let query = PFQuery(className:"Logs")
        query.limit = 1000
        query.fromLocalDatastore()
        query.addDescendingOrder("createdAt")
        //query.whereKey("user", equalTo:PFUser.current()?.username)
        
        query.findObjectsInBackground { (objects, error) in
            if error == nil {

                let number = objects?.count as! Int
                print ("number is", number)

                for i in 0 ..< number {
                    let curLog = objects?[i]
                    let activity = curLog?["activity"] as! String
                    let lon = curLog?["lon"] as! CLLocationDegrees
                    let lat = curLog?["lat"] as! CLLocationDegrees
                    let time =  curLog?["time"] as! String
                    let date = curLog?["date"] as! String
                    let log = Log(activity: activity, time: time, date: date, lat: lat, lon: lon)
                    self.logList.append(log)
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
        return self.logList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bundle = Bundle(for: TimelineTableViewCell.self)
        let nibUrl = bundle.url(forResource: "TimelineTableViewCell", withExtension: "bundle")
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell",
                                             bundle: Bundle(url: nibUrl!)!)
        tableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell",
                                                 for: indexPath) as! TimelineTableViewCell
        
        let log = self.logList[indexPath.row]
        configureCell(cell, withLog: log, at: indexPath)
        return cell
        
    }
    
    func configureCell(_ cell: TimelineTableViewCell, withLog log: Log, at ip: IndexPath) {
        
        let title = log.activity
        let time = log.time + " " + log.date
        
        cell.timelinePoint = TimelinePoint()
        if ip.row == 0{
            cell.timeline.frontColor = UIColor.clear
        } else {
            cell.timeline.frontColor = UIColor.flatMint
        }
        
        cell.timeline.backColor = UIColor.flatMint
        
        if (title?.hasPrefix("Indoor"))!{
            cell.bubbleColor = UIColor.flatYellow
        }
        if (title?.hasPrefix("Outdoor"))! {
            cell.bubbleColor = UIColor.flatGreen
        }
        cell.titleLabel.text = title
        cell.descriptionLabel.text = time
        cell.lineInfoLabel.text = nil
        cell.thumbnailImageView.image = nil
        cell.illustrationImageView.image = nil
    }
    
    
    
    /*
    //Core Data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bundle = Bundle(for: TimelineTableViewCell.self)
        let nibUrl = bundle.url(forResource: "TimelineTableViewCell", withExtension: "bundle")
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell",
                                             bundle: Bundle(url: nibUrl!)!)
        tableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell",
                                                 for: indexPath) as! TimelineTableViewCell
        
        let log = fetchedResultsController.object(at: indexPath)
        
        configureCell(cell, withEvent: log, at: indexPath)
        return cell
        
    }
    

    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newEvent = Log(context: context)
        
        // If appropriate, configure the new managed object.
        newEvent.timestamp = Date()
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: TimelineTableViewCell, withEvent event: Log, at ip: IndexPath) {

        let detail = event.act1!.description
        let act2 = event.act2!.description
        let time = event.time!.description
        
        cell.timelinePoint = TimelinePoint()
        if ip.row == 0{
            cell.timeline.frontColor = UIColor.clear
        } else {
            cell.timeline.frontColor = UIColor.flatMint
        }
        
        cell.timeline.backColor = UIColor.flatMint
        let title = detail + " - " + act2

        if title.hasPrefix("Indoor"){
            cell.bubbleColor = UIColor.flatYellow
        }
        if title.hasPrefix("Outdoor") {
            cell.bubbleColor = UIColor.flatGreen
        }
        cell.titleLabel.text = title
        cell.descriptionLabel.text = time
        cell.lineInfoLabel.text = nil
        cell.thumbnailImageView.image = nil
        cell.illustrationImageView.image = nil
    }
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Log> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "date", cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Log>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .left)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .left)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .left)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .left)

        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)! as! TimelineTableViewCell, withEvent: anObject as! Log, at: indexPath!)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)! as! TimelineTableViewCell, withEvent: anObject as! Log, at: indexPath!)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        tableView.reloadData()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    @IBAction func export(_ sender: Any) {
        
        let mailComposeViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else
        {
            self.showSendMailErrorAlert()
        }
        
        //SCLAlertView().showInfo("To-do", subTitle: "This will export the data.")
    
    }
    
    func writeCoreObjectsToCSV(objects: [NSManagedObject]) -> NSMutableString
    {
        // Make sure we have some data to export
        guard objects.count > 0 else {return ""}

        var mailString = NSMutableString()
        mailString.append("date, time, act1, act2, lat, lon")
        
        for object in objects
        {
            mailString.append("\n\(object.value(forKey: "date")!),\(object.value(forKey: "time")!), \(object.value(forKey: "act1")!),\(object.value(forKey: "act2")!),\(object.value(forKey: "lat")!),\(object.value(forKey: "lon")!)")
        }
        return mailString
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController
    {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setSubject("Log Data")
        mailComposerVC.setMessageBody("", isHTML: false)
        mailComposerVC.setToRecipients(["c040120@gmail.com"])
        var CoreDataResultsList = [NSManagedObject]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Log")
        do {
            let results =
                try managedObjectContext!.fetch(fetchRequest)
            CoreDataResultsList = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        let csvString = writeCoreObjectsToCSV(objects: CoreDataResultsList)
        let data = csvString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
            mailComposerVC.addAttachmentData(data!, mimeType: "text/csv", fileName: "log.csv")
    
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResult.saved.rawValue:
            print("Mail saved")
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent")
            SCLAlertView().showSuccess("Data Sent", subTitle: "Thanks!")
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: %@", [error!.localizedDescription])
            
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    */
    

}

