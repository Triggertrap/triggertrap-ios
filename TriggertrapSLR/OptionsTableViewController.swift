//
//  OptionsTableViewController.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 08/09/2014.
//  Copyright (c) 2014 Triggertrap Ltd. All rights reserved.
//

import UIKit
import CTFeedback

class OptionsTableViewController: UIViewController {
    
    fileprivate let applicationDelegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate var options: NSArray?
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        options = NSArray(contentsOfFile: pathForResource("Options"))
        //        GenerateStringsFileFromPlist("Options")
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.separatorColor = UIColor.clear
        
        tableView.register(UINib(nibName: "ModeTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ModeTableViewCell")
        
        // Hide previous screen title from the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applyTheme()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *){
            applyTheme()
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    fileprivate func applyTheme() {
        self.navigationController?.navigationBar.barTintColor = UIColor.triggertrap_primaryColor(1.0)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.triggertrap_iconColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.triggertrap_metric_regular(23.0), NSAttributedString.Key.foregroundColor: UIColor.triggertrap_iconColor(1.0)]
        
        self.view.backgroundColor = UIColor.triggertrap_naturalColor()
        self.tableView.backgroundColor = UIColor.triggertrap_naturalColor()
        self.tableView.reloadData()
    }
}

extension OptionsTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return options?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((options?[section] as AnyObject).object(at: 1) as! NSArray).count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModeTableViewCell", for: indexPath) as! ModeTableViewCell
        
        if let options = options, let optionsSection = (options[indexPath.section] as? NSArray), let optionsInSection = optionsSection[1] as? NSArray, let option = optionsInSection[indexPath.row] as? NSDictionary {
            
            
            cell.titleLabel.text = NSLocalizedString(option["title"] as! String, tableName: "OptionsPlist", bundle: Bundle.main, value: "Title", comment: "Ignore when translating")
            
            cell.titleLabel.textColor = UIColor.triggertrap_accentColor()
            cell.identifier = option["identifier"] as? String
            cell.backgroundColor = UIColor.triggertrap_fillColor()
            cell.icon.image = ImageWithColor(UIImage(named: option["icon"] as! String)!, color: UIColor.triggertrap_iconColor())
            cell.usesSmartColor = false
            cell.backgroundFadeColor = UIColor.triggertrap_fillColor()
            cell.descriptionLabel.text = NSLocalizedString(option["description"] as! String, tableName: "OptionsPlist", bundle: Bundle.main, value: "Description", comment: "Ignore when translating")
            cell.square.backgroundColor = UIColor.triggertrap_primaryColor()
            cell.descriptionLabel.textColor = UIColor.triggertrap_foregroundColor()
            cell.separatorView.backgroundColor = UIColor.triggertrap_clearColor()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 22.0))
        sectionBackgroundView.backgroundColor = UIColor.triggertrap_backgroundColor(1.0)
        
        let label = UILabel(frame: CGRect(x: 8, y: 0, width: self.tableView.frame.width, height: 22.0))
        
        label.text =  NSLocalizedString((options?[section] as AnyObject).object(at: 0) as! String, tableName: "OptionsPlist", bundle: Bundle.main, value: "Section", comment: "Ignore when translating")
        label.font = UIFont.triggertrap_metric_regular(18.0)
        label.textColor = UIColor.triggertrap_accentColor(1.0)
        
        sectionBackgroundView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                label.leftAnchor.constraint(equalTo: sectionBackgroundView.safeAreaLayoutGuide.leftAnchor, constant: 5.0)
            ])
        }
        
        return sectionBackgroundView
    }
}

extension OptionsTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? ModeTableViewCell, let identifier = cell.identifier {
            // The identifiers are set in the storyboard for each cell
            switch identifier {
            case "Feedback & Support":
                // Present the feedback and support controller
                let feedbackViewController = CTFeedbackViewController(topics: CTFeedbackViewController.defaultTopics(), localizedTopics: CTFeedbackViewController.defaultLocalizedTopics())
                
                feedbackViewController?.toRecipients = ["rossgibson@me.com"]
                feedbackViewController?.hidesAppNameCell = true
                
                self.navigationController?.navigationBar.barTintColor = UIColor(hex: 0xE2231A, alpha: 1.0)
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.triggertrap_metric_regular(23.0), NSAttributedString.Key.foregroundColor: UIColor.white]
                
                
                self.navigationController?.pushViewController(feedbackViewController!, animated: true)
                break
                
            case "Cable Selector":
                applicationDelegate.presentCableSelector(self)
                break
                
            case "Tutorial":
                applicationDelegate.presentTutorial(self)
                break
                
            case "Settings":
                self.performSegue(withIdentifier: "Settings", sender: self)
                break
                
            default:
                break
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
