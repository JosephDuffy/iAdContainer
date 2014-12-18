//
//  ExampleTableViewController.swift
//  iAdContainer
//
//  Created by Joseph Duffy on 16/12/2014.
//  Copyright (c) 2014 Yetii Ltd. All rights reserved.
//

import UIKit

class ExampleTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Yes, this is bad, but this is an example app
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "defaultCell")

        cell.textLabel?.text = "Cell at row \(indexPath.row) in section \(indexPath.section)"

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section + 1)"
    }

}
