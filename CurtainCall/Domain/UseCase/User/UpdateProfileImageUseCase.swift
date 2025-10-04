//
//  UpdateProfileImageUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import UIKit

final class UpdateProfileImageUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = UIImage
    typealias Output = Result<String, Error>
    
    // MARK: - Properties
    private let repository: UserRepositoryProtocol
    private let imageManager: ProfileImageManager
    
    // MARK: - Init
    init(
        repository: UserRepositoryProtocol,
        imageManager: ProfileImageManager = .shared
    ) {
        self.repository = repository
        self.imageManager = imageManager
    }
    
    // MARK: - Execute
    func execute(_ input: UIImage) -> Result<String, Error> {
        do {
            // 1. 이미지를 파일 시스템에 저장
            let imagePath = try imageManager.saveProfileImage(input)
            
            // 2. Realm에 이미지 경로 저장
            try repository.updateProfileImage(imagePath)
            
            return .success(imagePath)
        } catch {
            return .failure(error)
        }
    }
}
