//
//  ContentTableViewCell.swift
//  tunes
//
//  Created by Sergei Alexeev on 25.11.2020.
//

import UIKit

class ContentTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    private var currentUrlString = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.roundImage()
        self.loader.isHidden = false
    }
    
    private func roundImage() -> Void {
        self.imageViewCell.layer.cornerRadius = self.imageViewCell.frame.height / 2
        self.imageViewCell.layer.masksToBounds = true
        self.imageViewCell.layer.borderColor = UIColor.lightGray.cgColor
        self.imageViewCell.layer.borderWidth = 1.5
    }
    
    private func imageChange(image: UIImage?) -> Void {
        if let image = image {
            self.imageViewCell.image = image
            self.loader.isHidden = true
            self.loader.stopAnimating()
        } else {
            self.loader.isHidden = false
            self.loader.startAnimating()
            self.imageViewCell.image = nil
        }
    }
    
    public func loadImage(urlString: String) -> Void {
        self.imageChange(image: nil)
        guard let url = URL(string: urlString) else {
            return
        }
        
        self.currentUrlString = urlString
        DispatchQueue.global().async { [weak self, urlString] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                // при периспользовании может несколько разных приходить, нужна чтобы последняя запрашиваемая
                guard let currentUrl = self?.currentUrlString, urlString == currentUrl else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.imageChange(image: image)
                }
            }
        }
    }
}
