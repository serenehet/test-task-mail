//
//  ContentTableViewCell.swift
//  tunes
//
//  Created by Sergei Alexeev on 25.11.2020.
//

import UIKit

@IBDesignable class ContentTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageViewCell: UIImageView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageViewCell.layer.cornerRadius = self.imageViewCell.frame.height / 2
        self.imageViewCell.layer.masksToBounds = true
        self.imageViewCell.layer.borderColor = UIColor.lightGray.cgColor
        self.imageViewCell.layer.borderWidth = 1.5
        
        self.loader.isHidden = false
    }
    
    public func loadImage(urlString: String) -> Void {
        self.loader.isHidden = false
        self.loader.startAnimating()
        self.imageViewCell.image = nil
        
        let callback: () -> Void = { [weak self] in
            self?.loader.isHidden = true
            self?.loader.stopAnimating()
        }
        
        self.imageViewCell.load(urlString: urlString, callback: callback)
    }
}

fileprivate extension UIImageView {
    func load(urlString: String, callback: @escaping () -> Void ) -> Void {
        guard let url = URL(string: urlString) else {
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        callback()
                    }
                }
            }
        }
    }
}
