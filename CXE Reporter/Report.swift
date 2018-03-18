//
//  Report.swift
//  CXE Reporter
//
//  Created by Muhammad Ali on 2/20/18.
//  Copyright © 2018 Customer Experience EcoSystem. All rights reserved.
//

import Foundation

protocol HasToBeProvidedByTheUser {
    var isProvided: Bool { get }
    var notProvidedFields: [String] { get }
}

class Report: NSObject {
    func send(callback: @escaping (Bool) -> Void) {
        ServerCommunicator.shared.send(reportJSON: self.json, callback: callback)
    }
    
    private var json: [String: Any] {
        return [
            Field.department.key: self.department.json,
            Field.problemType.key: self.problemType.json,
            Field.location.key: self.location.json,
            Field.note.key: self.note ?? "",
        ]
    }
    
    enum Field {
        case department
        case problemType
        case location
        case note
        
        var description: String {
            switch self {
            case .department:
                return "Department"
            case .problemType:
                return "Problem Type"
            case .location:
                return "Location"
            case .note:
                return "Note"
            }
        }

        var key: String {
            switch self {
            case .department:
                return "department"
            case .problemType:
                return "problemType"
            case .location:
                return "location"
            case .note:
                return "note"
            }
        }
        
        var isDepartmentOrProblemType: Bool {
            return (
                (self == .department) ||
                (self == .problemType)
            )
        }
    }
    
    private var department: Department {
        return self.similarlyHandledFields[.department] as! Department
    }

    private var problemType: ProblemType {
        return self.similarlyHandledFields[.problemType] as! ProblemType
    }

    let similarlyHandledFields: [Field: LeafItem] = [
        .department: Department(server_id: "", title: ""),
        .problemType: ProblemType(server_id: "", title: ""),
    ]

    var location = Location()
    var note: String?
    
    func update(field: Field, from leafItem: LeafItem) {
        switch field {
        case .department, .problemType:
            self.similarlyHandledFields[field]!.update(from: leafItem)
        default:
            break
        }
    }
}

extension Report: HasToBeProvidedByTheUser {
    var isProvided: Bool {
        if !self.department.isProvided {
            return false
        }
        if !self.problemType.isProvided {
            return false
        }
        if !self.location.isProvided {
            return false
        }
        return true
    }

    var notProvidedFields: [String] {
        var incompleteInReport: [String] = []
        for (field, leafItem) in self.similarlyHandledFields {
            if !leafItem.isProvided {
                incompleteInReport.append(field.description)
            }
        }
        if !self.location.isProvided {
            let notProvidedFieldsInLocation = self.location.notProvidedFields
            let string = notProvidedFieldsInLocation.joined(separator: ",")
            incompleteInReport.append("[\(string)] in \(Report.Field.location.description)")
        }
        return incompleteInReport
    }
}
