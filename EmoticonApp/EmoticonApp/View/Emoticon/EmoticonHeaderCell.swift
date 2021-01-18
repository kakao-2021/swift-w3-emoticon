//
//  EmoticonHeaderCell.swift
//  EmoticonApp
//
//  Created by 지현우 on 2021/01/18.
//

import UIKit

class EmoticonHeaderCell: UITableViewHeaderFooterView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "pattern") ?? UIImage())
        self.backgroundView = backgroundView
    }
}
