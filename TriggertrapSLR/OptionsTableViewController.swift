//
//  OptionsTableViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 08/09/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit

class OptionsTableViewController: UIViewController {
    
    private let applicationDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private var options: NSArray?
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        options = NSArray(contentsOfFile: pathForResource("Options"))
        //        GenerateStringsFileFromPlist("Options")
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.separatorColor = UIColor.clearColor()
        
        tableView.registerNib(UINib(nibName: "ModeTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "ModeTableViewCell")
        
        // Hide previous screen title from the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        applyTheme()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func applyTheme() {
        
        switch AppTheme() {
        case .Normal:
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
            break
        case .Night:
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
            break
        }
        
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.triggertrap_iconColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.triggertrap_metric_regular(23.0), NSForegroundColorAttributeName: UIColor.triggertrap_iconColor(1.0)]
        
        self.view.backgroundColor = UIColor.triggertrap_naturalColor()
        self.tableView.backgroundColor = UIColor.triggertrap_naturalColor()
        self.tableView.reloadData()
    }
}

extension OptionsTableViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return options?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (options?[section].objectAtIndex(1) as! NSArray).count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ModeTableViewCell", forIndexPath: indexPath) as! ModeTableViewCell
        
        if let options = options, optionsSection = (options[indexPath.section] as? NSArray), optionsInSection = optionsSection[1] as? NSArray, option = optionsInSection[indexPath.row] as? NSDictionary {
            
            
            cell.titleLabel.text = NSLocalizedString(option["title"] as! String, tableName: "OptionsPlist", bundle: NSBundle.mainBundle(), value: "Title", comment: "Ignore when translating")
            
            cell.titleLabel.textColor = UIColor.triggertrap_accentColor()
            cell.identifier = option["identifier"] as? String
            cell.backgroundColor = UIColor.triggertrap_fillColor()
            cell.icon.image = ImageWithColor(UIImage(named: option["icon"] as! String)!, color: UIColor.triggertrap_iconColor())
            cell.usesSmartColor = false
            cell.backgroundFadeColor = UIColor.triggertrap_fillColor()
            cell.descriptionLabel.text = NSLocalizedString(option["description"] as! String, tableName: "OptionsPlist", bundle: NSBundle.mainBundle(), value: "Description", comment: "Ignore when translating")
            cell.square.backgroundColor = UIColor.triggertrap_primaryColor()
            cell.descriptionLabel.textColor = UIColor.triggertrap_foregroundColor()
            cell.separatorView.backgroundColor = UIColor.triggertrap_clearColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 22.0))
        view.backgroundColor = UIColor.triggertrap_backgroundColor(1.0)
        
        let label = UILabel(frame: CGRect(x: 8, y: 0, width: self.tableView.frame.width, height: 22.0))
        
        label.text =  NSLocalizedString(options?[section].objectAtIndex(0) as! String, tableName: "OptionsPlist", bundle: NSBundle.mainBundle(), value: "Section", comment: "Ignore when translating")
        label.font = UIFont.triggertrap_metric_regular(18.0)
        label.textColor = UIColor.triggertrap_accentColor(1.0)
        
        view.addSubview(label)
        
        return view
    }
}

extension OptionsTableViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ModeTableViewCell, identifier = cell.identifier {
            // The identifiers are set in the storyboard for each cell
            switch identifier {
            case "Feedback & Support":
                // Present the feedback and support controller
                let feedbackViewController = CTFeedbackViewController(topics: CTFeedbackViewController.defaultTopics(), localizedTopics: CTFeedbackViewController.defaultLocalizedTopics())
                
                feedbackViewController.toRecipients = ["hello@triggertrap.com"]
                feedbackViewController.hidesAppNameCell = true
                
                self.navigationController?.navigationBar.barTintColor = UIColor(hex: 0xE2231A, alpha: 1.0)
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
                self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.triggertrap_metric_regular(23.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
                
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
                
                self.navigationController?.pushViewController(feedbackViewController, animated: true)
                break
                
            case "Cable Selector":
                applicationDelegate.presentCableSelector(self)
                break
                
            case "Tutorial":
                applicationDelegate.presentTutorial(self)
                break
                
            case "Inspiration":
                applicationDelegate.presentInspiration(self)
                break
                
            case "Settings":
                self.performSegueWithIdentifier("Settings", sender: self)
                break
                
            default:
                break
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
