//
//  CategoricalTreeTableViewController.swift
//  CXE Reporter
//
//  Created by Muhammad Ali on 2/18/18.
//  Copyright © 2018 Customer Experience EcoSystem. All rights reserved.
//

import UIKit

class CategoricalTreeTableViewController: UITableViewController {
    
    var data: [Selectable] = [
        Category(server_id: "c1", title: "Category1", children: [
            Category(server_id: "c11", title: "Category11", children: [
                LeafItem(server_id: "i111", title: "Item111"),
                LeafItem(server_id: "i112", title: "Item112"),
                LeafItem(server_id: "i113", title: "Item113"),
                LeafItem(server_id: "i114", title: "Item114"),
            ]),
            LeafItem(server_id: "i11", title: "Item11"),
            LeafItem(server_id: "i12", title: "Item12"),
            LeafItem(server_id: "i13", title: "Item13"),
            LeafItem(server_id: "i14", title: "Item14"),

        ]),
        LeafItem(server_id: "i1", title: "Item1"),
        LeafItem(server_id: "i2", title: "Item2"),
        LeafItem(server_id: "i3", title: "Item3"),
        LeafItem(server_id: "i4", title: "Item4"),
        ] {
        didSet {
            self.updateUI()
        }
    }
    
    var selectionDelegate: ReportingFormViewControllerLeafItemSelectionDelegate?
    
    private func addOtherOption() {
        let otherOption = LeafItem(server_id: "", title: "Other")
        otherOption.controlType = .notListed
        self.data.append(otherOption)
    }
    
    private func updateValues() {
        self.categories = data.categories
        self.leafItems = data.leafItems
    }
    
    private func updateUI() {
        self.updateValues()
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }

    private var categories: [Category] = []
    private var leafItems: [LeafItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.addOtherOption()
        self.updateValues()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == categories.count {
            return leafItems.count
        } else {
            return categories[section].children.count
        }
    }
    
    private func getSelectable(for indexPath: IndexPath) -> Selectable {
        var selectable: Selectable?
        if indexPath.section == categories.count {
            selectable = leafItems[indexPath.row]
        } else {
            selectable = categories[indexPath.section].children[indexPath.row]
        }
        return selectable!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        let selectable = self.getSelectable(for: indexPath)
        if indexPath.section == categories.count {
            cell  = tableView.dequeueReusableCell(withIdentifier: "leafRow", for: indexPath)
        } else {
            if selectable is Category {
                cell = tableView.dequeueReusableCell(withIdentifier: "nonLeafRow", for: indexPath)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "leafRow", for: indexPath)
            }
        }
        if let label = cell?.viewWithTag(1) as? UILabel {
            label.text = selectable.title
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constant.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let view = Bundle.main.loadNibNamed("SelectableView", owner: self, options: nil)?.first as? SelectableView {
            let selectable: Selectable?
            if section == categories.count {
                selectable = Category(server_id: "-1", title: "Others", children: [])
            } else {
                selectable = data[section]
            }
            view.selectable = selectable!
            return view
        }
        return nil
    }
    
    private func initSelfInstanceForChildren(of category: Category) {
        if let categoricalTreeTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CategoricalTreeTableViewController") as? CategoricalTreeTableViewController {
            let data = category.children
            categoricalTreeTableViewController.data = data
            categoricalTreeTableViewController.selectionDelegate = self.selectionDelegate
            categoricalTreeTableViewController.title = category.title
            self.navigationController?.pushViewController(categoricalTreeTableViewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectable = getSelectable(for: indexPath)
        if selectable is Category {
            self.initSelfInstanceForChildren(of: selectable as! Category)
        } else {
            self.selectionDelegate?.didSelect(leafItem: selectable as! LeafItem)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            navigationController?.popToRootViewController(animated: true)
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
