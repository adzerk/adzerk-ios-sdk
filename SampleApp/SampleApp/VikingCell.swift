//
//  VikingCell.swift
//  SampleApp
//
//  Created by Ben Scheirman on 8/18/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import UIKit

class VikingCell : UITableViewCell {
    static let identifier : String = "VikingCell"
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var quoteLabel: UILabel!
    @IBOutlet var vikingImageView: RemoteImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        quoteLabel.text = ""
        vikingImageView.image = nil
        vikingImageView.task?.cancel()
    }
}
