//
//  DetailPosterCell.swift
//  CurtainCall
//
//  Created by 서준일 on 9/29/25.
//

import UIKit
import SnapKit
import RxSwift
import CachingKit

final class DetailPosterCell: BaseCollectionViewCell {

    // MARK: - Properties
    private var imageAspectRatio: CGFloat = 1.0
    private var currentURL: String?

    // MARK: - UI Components
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        posterImageView.ck_cancelImageLoad()
        imageAspectRatio = 1.0
        currentURL = nil
    }

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

    // MARK: - Self-Sizing Support
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        // 너비는 고정, 높이는 이미지 비율에 따라 계산
        let width = layoutAttributes.frame.width
        let height = width / imageAspectRatio

        attributes.frame.size = CGSize(width: width, height: height)
        return attributes
    }

    // MARK: - Configure
    func configure(with url: String) {
        currentURL = url

        guard let imageURL = url.safeImageURL else { return }

        // placeholder 설정
        posterImageView.image = UIImage(systemName: "photo")

        // CachingKit을 사용하여 이미지 로드
        Task { @MainActor in
            // 현재 셀이 재사용되어 다른 URL을 로드 중인지 확인
            guard self.currentURL == url else { return }

            let screenWidth = UIScreen.main.bounds.width
            // 세로로 긴 이미지를 고려하여 충분한 높이 설정
            let targetSize = CGSize(width: screenWidth, height: screenWidth * 3)

            if let loadedImage = await CachingKit.shared.loadImage(
                url: imageURL,
                targetSize: targetSize,
                cacheStrategy: .both
            ) {
                // 재사용 체크
                guard self.currentURL == url else { return }

                // 이미지 비율 계산 (width / height)
                self.imageAspectRatio = loadedImage.size.width / loadedImage.size.height

                // 이미지 설정
                self.posterImageView.image = loadedImage

                // 셀 크기 재계산 요청
                self.invalidateIntrinsicContentSize()
                if let collectionView = self.superview as? UICollectionView {
                    collectionView.collectionViewLayout.invalidateLayout()
                }
            }
        }
    }
}
