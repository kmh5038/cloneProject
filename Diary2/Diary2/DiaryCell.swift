//
//  DiaryCell.swift
//  Diary2
//
//  Created by 김명현 on 2023/08/17.
//

import UIKit

class DiaryCell: UICollectionViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    // contentView가 cell의 rootView
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.borderWidth = 1.0
    }
}
