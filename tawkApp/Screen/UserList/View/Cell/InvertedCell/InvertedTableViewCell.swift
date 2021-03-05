//
//  InvertedTableViewCell.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 03.03.2021.
//

import UIKit
import Combine

class InvertedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    private var cancellable: AnyCancellable?
    private var animation: UIViewPropertyAnimator?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .mainCellBg
        userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.width / 2
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        userAvatarImageView.image = nil
        userAvatarImageView.alpha = 0.0
        animation?.stopAnimation(true)
        cancellable?.cancel()
        contentView.backgroundColor = .mainCellBg
    }
}

extension InvertedTableViewCell {
    //Setup congigure cell
    func configCell(_ user: UserViewModel, invert: Bool) {
        self.userNameLabel.text = user.userName ?? "Username is empty"
        self.cancellable = self.loadImage(for: user).sink { [unowned self] image in
            self.showImage(image: image, invert: invert)
        }
    }
    
    // Show load image
    private func showImage(image: UIImage?, invert: Bool) {
        self.userAvatarImageView.image = image
        
        if invert,
           let filter = CIFilter(name: "CIColorInvert"),
           let image = image,
           let ciimage = CIImage(image: image) {
            filter.setValue(ciimage, forKey: kCIInputImageKey)
            let newImage = UIImage(ciImage: filter.outputImage!)
            self.userAvatarImageView.image = newImage
        }
        animation = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.userAvatarImageView.alpha = 1.0
        })
    }
    
    private func loadImage(for user: UserViewModel) -> AnyPublisher<UIImage?, Never> {
        return Just(user.avatarUrl)
            .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
                let url = URL(string: user.avatarUrl ?? "")!
                return ImageLoader.shared.loadImage(from: url)
            })
            .eraseToAnyPublisher()
    }
}
