//
//  LocationSpecificsTableViewController.swift
//  CXE Reporter
//
//  Created by Muhammad Ali on 2/26/18.
//  Copyright © 2018 Customer Experience EcoSystem. All rights reserved.
//

import UIKit

class LocationSpecificsTableViewController: UITableViewController {
    var location = Location()
    
    var data: [Location.Specification] {
        return location.specifics
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].options.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leafRow", for: indexPath)
        let specific = data[indexPath.section]
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = specific.options[indexPath.row]
            if self.location.currentSelected(for: specific) == indexPath.row {
                cell.accessoryType = .checkmark
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let specification = data[indexPath.section]
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .none {
                if let selected = location.currentSelected(for: specification) {
                    let lastSelectedIndexPath = IndexPath(row: selected, section: indexPath.section)
                    let lastSelectedCell = tableView.cellForRow(at: lastSelectedIndexPath)
                    lastSelectedCell?.accessoryType = .none
                }
                cell.accessoryType = .checkmark
                self.location.updateSelected(specification: specification, with: indexPath.row)
                
            } else {
                self.location.removeSelected(for: specification)
                cell.accessoryType = .none
            }
        }
    }
}
