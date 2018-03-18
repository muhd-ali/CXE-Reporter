//
//  SelectableView.swift
//  CXE Reporter
//
//  Created by Muhammad Ali on 3/18/18.
//  Copyright © 2018 Customer Experience EcoSystem. All rights reserved.
//

import UIKit

class SelectableView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    
    var selectable: Selectable? {
        didSet {
            if (selectable != nil) {
                updateUI(from: selectable!)
            }
        }
    }

    private func updateUI(from selectable: Selectable) {
        titleLabel.text = selectable.title
    }
}
