//
//  PosterCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import RxSwift
import SnapKit
import Kingfisher

// MARK: - PosterCell
final class PosterCell: BaseCollectionViewCell {
    
    // MARK: - UI Components
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    override func setupHierarchy() {
        super.setupHierarchy()
        contentView.addSubview(posterImageView)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        posterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with url: String) {
        if let imageURL = url.safeImageURL {
            posterImageView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(systemName: "photo.circle")?.withTintColor(.ccPrimary, renderingMode: .alwaysOriginal)
            )
        }
    }
}
