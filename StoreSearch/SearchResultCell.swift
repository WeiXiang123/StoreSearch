//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by WeiXiang on 15/1/12.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!



    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let selectedView = UIView(frame: CGRect.zeroRect)
        selectedView.backgroundColor = UIColor(red: 20/255.0, green: 160/255.0, blue: 160/255.0, alpha: 0.5)
        selectedBackgroundView = selectedView

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
