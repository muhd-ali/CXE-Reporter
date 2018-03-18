//
//  ReportingFormViewController.swift
//  CXE Reporter
//
//  Created by Muhammad Ali on 2/18/18.
//  Copyright © 2018 Customer Experience EcoSystem. All rights reserved.
//

import UIKit
import class PKHUD.HUD
import IQKeyboardManager

protocol ReportingFormViewControllerLeafItemSelectionDelegate {
    func didSelect(leafItem: LeafItem)
}

class ReportingFormViewController: UIViewController {
    @IBOutlet weak var reportingFormTableView: UITableView!

    func takeScreenShot() -> UIImageView {
        UIGraphicsBeginImageContextWithOptions(self.reportingFormTableView.frame.size, true, 0.5)
        self.reportingFormTableView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        let view = UIImageView(image: image)
        view.frame = self.reportingFormTableView.frame
        view.layer.borderColor = UIColor.clear.cgColor
        self.view.addSubview(view)
        UIGraphicsEndImageContext()
        return view
    }
    
    func makeTransformation(for view: UIImageView) -> CATransform3D {
        let viewFrame = view.frame
        let orgSize = viewFrame.size
        var transform = CATransform3DIdentity
        let xScale = CGFloat(0.1)
        let yScale = CGFloat(0.1)
        var xTrans = -orgSize.width * (1 - xScale) / 2
        var yTrans = orgSize.height * (1 - yScale) / 2
        if let historyTab = self.tabBarController?.tabBar.subviews[1] {
            xTrans = -(viewFrame.midX - historyTab.frame.midX)
            yTrans = (viewFrame.midY - historyTab.frame.midY)
        }
        transform = CATransform3DTranslate(transform, xTrans, yTrans, 0)
        transform = CATransform3DScale(transform, xScale, yScale, 1)
        return transform
    }
    
    private func resetView() {
        self.report = Report()
        self.reportingFormTableView.reloadData()
    }
    
    func runSendAnimation() {
        let view = self.takeScreenShot()
        HUD.show(.progress)
        let report = self.report
        self.resetView()
        let transform = self.makeTransformation(for: view)
        UIView.animate(
            withDuration: Constant.animationDelay,
            animations: {
                view.layer.transform = transform
                }) { (completed) in
                    report.send { (wasSuccessful) in
                        if wasSuccessful {
                            view.removeFromSuperview()
                            HUD.hide()
                            HUD.flash(.labeledSuccess(title: "Done", subtitle: "Report Sent"), delay: Constant.animationDelay)
                        } else {
                            UIView.animate(
                                withDuration: Constant.animationDelay,
                                animations: {
                                    view.layer.transform = CATransform3DIdentity
                                },
                                completion: { (completed) in
                                    self.report = report
                                    self.reportingFormTableView.reloadData()
                                    view.removeFromSuperview()
                                    HUD.hide()
                                    HUD.flash(.labeledError(title: "Try Again", subtitle: "Something went wrong!"), delay: Constant.animationDelay)
                                }
                            )
                        }
                    }
        }

    }
    
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        self.makeSureLocationIsEnabled()
        if self.report.isProvided {
            self.runSendAnimation()
        } else {
            let incomplete = self.report.notProvidedFields.joined(separator: ",")
            HUD.flash(
                .labeledError(title: "Incomplete", subtitle: "\(incomplete)"),
                delay: Constant.animationDelay
            )
        }
    }
    
    private var report = Report()
    
    private let formFields: [Report.Field] = [
        .department,
        .problemType,
        .location,
        .note,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Report"
        navigationController?.navigationBar.prefersLargeTitles = true
        self.reportingFormTableView.tableFooterView = UIView(frame: CGRect.zero)
        reportingFormTableView.dataSource = self
        reportingFormTableView.delegate = self
        self.makeSureLocationIsEnabled()
    }
    
    private func makeSureLocationIsEnabled() {
        let gpsLocation = Location.GPS.shared
        gpsLocation.locationManager.requestWhenInUseAuthorization()
        if !gpsLocation.hasAccess {
            self.showLocationDisabledPopUp()
        }
    }
    
    private func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Access Disabled",
                                                message: "Your location needs to be added in the report.",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.resignFirstResponder()
        if self.isViewLoaded {
            if let indexForLocation = self.formFields.index(of: .location) {
                let indexPath = IndexPath(row: 0, section: indexForLocation)
                let locationSpecificsString = self.report.location.specificsString
                self.updateCellText(for: indexPath, with: locationSpecificsString)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var currentlySelected: IndexPath?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? CategoricalTreeTableViewController,
           segue.identifier == "showCategoryController" {
            if let field = sender as? Report.Field {
                dvc.title = field.description
                switch field {
                case .department:
                    dvc.data = Department.SampleData
                case .problemType:
                    dvc.data = ProblemType.SampleData
                default:
                    break
                }
            }
            dvc.selectionDelegate = self
        } else if let dvc = segue.destination as? LocationSpecificsTableViewController,
                  segue.identifier == "showLocationSpecifics" {
            dvc.location = self.report.location
        }
    }
}

extension ReportingFormViewController: ReportingFormViewControllerLeafItemSelectionDelegate {
    private func updateCell(for indexPath: IndexPath, with leafItem: LeafItem) {
        self.updateCellText(for: indexPath, with: leafItem.title)
    }
    
    private func reset(cell: UITableViewCell) {
        if let label = cell.viewWithTag(1) as? UILabel {
            cell.accessoryType = .none
            label.text = "Tap to Select"
            label.textColor = UIColor.lightGray
        }
    }
    
    private func updateText(for cell: UITableViewCell, with text: String) {
        cell.isSelected = false
        if !text.isEmpty {
            if let label = cell.viewWithTag(1) as? UILabel {
                cell.accessoryType = .checkmark
                label.text = text
                label.textColor = UIColor.black
            }
        } else {
            self.reset(cell: cell)
        }
    }
    
    private func updateCellText(for indexPath: IndexPath, with text: String) {
        if let cell = self.reportingFormTableView.cellForRow(at: indexPath) {
            self.updateText(for: cell, with: text)
        }
    }
    
    private func addRowForOtherOption(for indexPath: IndexPath, with leafItem: LeafItem) {
        let nextIndex = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        self.reportingFormTableView.beginUpdates()
        self.reportingFormTableView.insertRows(at: [nextIndex], with: .automatic)
        self.reportingFormTableView.endUpdates()
    }
    
    private func removeRowForOtherOption(for indexPath: IndexPath, with leafItem: LeafItem) {
        let nextIndex = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        self.reportingFormTableView.beginUpdates()
        self.reportingFormTableView.deleteRows(at: [nextIndex], with: .automatic)
        self.reportingFormTableView.endUpdates()

    }

    private func runControl(for leafItem: LeafItem, at indexPath: IndexPath) {
        if leafItem.controlType == .notListed {
            self.addRowForOtherOption(for: indexPath, with: leafItem)
        } else {
            self.removeRowForOtherOption(for: indexPath, with: leafItem)
        }
    }

    private func updateTable(for indexPath: IndexPath, with leafItem: LeafItem) {
        self.updateCell(for: indexPath, with: leafItem)
        if !self.tableViewHasCorrectNumberOfRows(for: indexPath, with: leafItem) {
            self.runControl(for: leafItem, at: indexPath)
        }
    }
    
    private func tableViewHasCorrectNumberOfRows(for selected: IndexPath, with leafItem: LeafItem) -> Bool {
        return ((leafItem.controlType == .notListed &&
                self.reportingFormTableView.numberOfRows(inSection: selected.section) == 2)) ||
                (leafItem.controlType == .none &&
                self.reportingFormTableView.numberOfRows(inSection: selected.section) == 1)
    }

    func didSelect(leafItem: LeafItem) {
        if let selected = self.currentlySelected {
            self.report.update(field: self.formFields[selected.section], from: leafItem)
            self.updateTable(for: selected, with: leafItem)
        }
    }
}

extension ReportingFormViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return formFields.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let field = self.formFields[section]
        switch field {
        case .department, .problemType:
            if report.similarlyHandledFields[field]!.controlType == .notListed {
                return 2
            } else {
                return 1
            }
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.row == 0 {
            let field = self.formFields[indexPath.section]
            switch field {
            case .note:
                cell = tableView.dequeueReusableCell(withIdentifier: "NoteRow", for: indexPath)
                if let textView = cell?.viewWithTag(1) as? UITextView {
                    textView.text = self.report.note
                    textView.delegate = self
                }
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: "SelectionRow", for: indexPath)
                switch field {
                case .department, .problemType:
                    self.updateText(for: cell!, with: self.report.similarlyHandledFields[field]!.title)
                case .location:
                    self.updateText(for: cell!, with: self.report.location.specificsString)
                default:
                    break
                }
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "OtherRow", for: indexPath)
            cell?.selectionStyle = .none
            if let textField = cell?.viewWithTag(1) as? UITextField {
                textField.delegate = self
                let field = self.formFields[indexPath.section]
                textField.placeholder = "Enter " + field.description
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let field = self.formFields[section]
        var title = ""
        switch field {
        case .note:
            title = field.description + " (Optional)"
        default:
            title = formFields[section].description
        }
        return title
    }
}

extension ReportingFormViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let note = textView.text
        if !note!.isEmpty {
            self.report.note = note
        } else {
            self.report.note = nil
        }
        IQKeyboardManager.shared().isEnableAutoToolbar = false
    }
}

extension ReportingFormViewController: UITextFieldDelegate {
    private func updateRowUI(in textField: UITextField) -> UITableViewCell? {
        if let cell = textField.superview?.superview as? UITableViewCell {
            if (!textField.text!.isEmpty) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
        return nil
    }
    
    private func saveEnteredTextToReport(for cell: UITableViewCell, with textfield: UITextField) {
        if let indexPath = self.reportingFormTableView.indexPath(for: cell) {
            let field = self.formFields[indexPath.section]
            let leafItem = self.report.similarlyHandledFields[field]
            leafItem?.title = textfield.text!
        }
    }

    private func validateAndStoreEnteredName(in textField: UITextField) {
        if let cell = self.updateRowUI(in: textField) {
            self.saveEnteredTextToReport(for: cell, with: textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        self.validateAndStoreEnteredName(in: textField)
    }
}

extension ReportingFormViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let field = self.formFields[indexPath.section]
        switch field {
        case .note:
            return 3 * Constant.rowHeight
        default:
            return Constant.rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            return
        }
        self.currentlySelected = indexPath
        let field = formFields[indexPath.section]
        switch field {
        case .department, .problemType:
            self.performSegue(withIdentifier: "showCategoryController", sender: field)
        case .location:
            self.performSegue(withIdentifier: "showLocationSpecifics", sender: field)
        default:
            break
        }
        return
    }
}
