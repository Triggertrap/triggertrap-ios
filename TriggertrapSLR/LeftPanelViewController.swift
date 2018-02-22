//
//  LeftPanelTableViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 01/08/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class LeftPanelViewController: UIViewController {
    
    // Cable Release modes
    @IBOutlet var tableView: UITableView! 
    
    private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    private var modes: NSArray?
    
    // MARK - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.separatorColor = UIColor.clearColor()
        
        tableView.registerNib(UINib(nibName: "ModeTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "ModeTableViewCell")
        
        modes = NSArray(contentsOfFile: pathForResource("Modes")) 
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LeftPanelViewController.removeActiveCell(_:)), name: "DidRemoveActiveViewController", object: nil) 
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
        self.view.backgroundColor = UIColor.triggertrap_fillColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews() 
        
        // Get superview if it exists
        if let superview = self.view.superview {
            
            // Get the table view origin from the superview
            let tableViewOrigin = superview.convertPoint(self.tableView.frame.origin, fromView: self.view)
            
            // Get status bar size
            let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
            
            // Change navigation bar height to the difference between table view origin and size of the status bar
            if let navigationBarFrame = self.navigationController?.navigationBar.frame {
                
                self.navigationController?.navigationBar.frame = CGRect(x: navigationBarFrame.origin.x, y: navigationBarFrame.origin.y, width: navigationBarFrame.size.width, height: tableViewOrigin.y - statusBarSize.height)
            }
        }
    }
    
    // MARK: - Notifications
    
    func removeActiveCell(sender: NSNotification) {
        self.tableView.reloadData()
    } 
}

extension LeftPanelViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return modes?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (modes?[section].objectAtIndex(1) as! NSArray).count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ModeTableViewCell", forIndexPath: indexPath) as! ModeTableViewCell
        
        if let modes = modes, modesSection = (modes[indexPath.section] as? NSArray), modesInSection = modesSection[1] as? NSArray, mode = modesInSection[indexPath.row] as? NSDictionary {
            
            cell.titleLabel.text = NSLocalizedString(mode["title"] as! String, tableName: "ModesPlist", bundle: NSBundle.mainBundle(), value: "Title", comment: "Ignore when translating")
            
            cell.titleLabel.textColor = UIColor.triggertrap_accentColor()
            cell.identifier = mode["identifier"] as? String
            cell.backgroundColor = UIColor.triggertrap_fillColor()
            cell.icon.image = ImageWithColor(UIImage(named: mode["icon"] as! String)!, color: UIColor.triggertrap_iconColor())
            cell.remoteSupported = mode["remoteSupported"] as! Bool
            cell.wearablesSupported = mode["wearablesSupported"] as! Bool
            cell.usesSmartColor = false
            cell.backgroundFadeColor = UIColor.triggertrap_fillColor()
            
            if WearablesManager.sharedInstance.isWearablesModeRunning() && !cell.wearablesSupported {
                cell.descriptionLabel.text = NSLocalizedString("Not available with Wearable mode running", comment: "Not available with Wearable mode running")
                cell.square.backgroundColor = UIColor.triggertrap_color(UIColor.triggertrap_naturalColor(), change: CGFloat(indexPath.row) * 0.1)
            } else if WifiDispatcher.sharedInstance.remoteOutputServer.delegate != nil && !cell.remoteSupported  {
                cell.descriptionLabel.text = NSLocalizedString("Not available with Wifi Master running", comment: "Not available with Wifi Master running")
                cell.square.backgroundColor = UIColor.triggertrap_color(UIColor.triggertrap_naturalColor(), change: CGFloat(indexPath.row) * 0.1)
            } else {
                cell.descriptionLabel.text = NSLocalizedString(mode["description"] as! String, tableName: "ModesPlist", bundle: NSBundle.mainBundle(), value: "Description", comment: "Ignore when translating")
                cell.square.backgroundColor = UIColor.triggertrap_color(UIColor.triggertrap_primaryColor(), change: CGFloat(indexPath.row) * 0.1)
            }
            
            cell.descriptionLabel.textColor = UIColor.triggertrap_foregroundColor()
            cell.separatorView.backgroundColor = UIColor.triggertrap_clearColor()
            
            if let activeViewController = SequenceManager.sharedInstance.activeViewController where cell.identifier == activeViewController.restorationIdentifier {
                cell.activityIndicator.startAnimating()
            } else {
                cell.activityIndicator.stopAnimating()
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 22.0))
        view.backgroundColor = UIColor.triggertrap_backgroundColor(1.0)
        
        let label = UILabel(frame: CGRect(x: 8, y: 0, width: self.tableView.frame.width, height: 22.0))
        
        label.text = NSLocalizedString(modes?[section].objectAtIndex(0) as! String, tableName: "ModesPlist", bundle: NSBundle.mainBundle(), value: "Section", comment: "Ignore when translating")
        label.font = UIFont.triggertrap_metric_regular(18.0)
        label.textColor = UIColor.triggertrap_accentColor(1.0)
        
        view.addSubview(label)
        
        return view
    } 
}

extension LeftPanelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ModeTableViewCell
        
        guard let identifier = cell.identifier else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        if WifiDispatcher.sharedInstance.remoteOutputServer.delegate != nil {
            
            if cell.remoteSupported {
                NSNotificationCenter.defaultCenter().postNotificationName("SidebarDidSelectCellWithIdentifier", object:identifier)
            }
        } else if WearablesManager.sharedInstance.isWearablesModeRunning() {
            if cell.wearablesSupported {
                NSNotificationCenter.defaultCenter().postNotificationName("SidebarDidSelectCellWithIdentifier", object:identifier)
            }
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("SidebarDidSelectCellWithIdentifier", object:identifier)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
