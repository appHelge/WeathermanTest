//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Helge Larsen on 14.06.15.
//  Copyright © 2015 Helge Larsen. All rights reserved.
//

//TODO: Use Dynamic Type for cell contents
/*
Exercise. Put Dynamic Type on the cells from the table view. There’s a catch: when the user returns from changing the text size settings, the app should refresh the screen without needing a restart. You can do this by reloading the table view when the app receives a UIContentSizeCategoryDidChangeNotification (see the previous tutorial for how to handle notifications).
*/

import UIKit

class SearchResultCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var artworkImageView: UIImageView!
  
  //var downloadTask: NSURLSessionDownloadTask?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let selectedView = UIView(frame: CGRect.zeroRect)
    selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
    selectedBackgroundView = selectedView
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    /*
    downloadTask?.cancel()
    downloadTask = nil
    */
    
    titleLabel.text = nil
    subtitleLabel.text = nil
    artworkImageView.image = nil
  }
  
  func configureForSearchResult(searchResult: LocationSearchResult) {
    titleLabel.text = searchResult.title
    subtitleLabel.text = searchResult.subtitle
  }
}
