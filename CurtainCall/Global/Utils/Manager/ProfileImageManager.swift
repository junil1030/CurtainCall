//
//  ProfileImageManager.swift
//  CurtainCall
//
//  Created by 서준일 on 10/4/25.
//

import UIKit
import OSLog

final class ProfileImageManager {
    
    // MARK: - Singleton
    static let shared = ProfileImageManager()
    
    // MARK: - Properties
    private let fileManager = FileManager.default
    private let profileImageFileName = "profile_image.jpg"
    private let compressionQuality: CGFloat = 0.8
    
    // MARK: - Init
    private init() {
        createProfileDirectoryIfNeeded()
    }
    
    // MARK: - Directory Management
    
    /// 프로필 이미지 디렉토리 경로
    private var profileImageDirectory: URL {
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentDirectory.appendingPathComponent("ProfileImages", isDirectory: true)
    }
    
    /// 프로필 이미지 파일 전체 경로
    private var profileImageURL: URL {
        return profileImageDirectory.appendingPathComponent(profileImageFileName)
    }
    
    /// 프로필 이미지 디렉토리 생성
    private func createProfileDirectoryIfNeeded() {
        guard !fileManager.fileExists(atPath: profileImageDirectory.path) else { return }
        
        do {
            try fileManager.createDirectory(
                at: profileImageDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            Logger.data.info("프로필 이미지 디렉토리 생성 완료: \(self.profileImageDirectory.path)")
        } catch {
            Logger.data.error("프로필 이미지 디렉토리 생성 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public Methods
    
    /// 프로필 이미지 저장 (기존 이미지 삭제 후 새 이미지 저장)
    /// - Parameter image: 저장할 UIImage
    /// - Returns: 저장된 이미지 파일명 (상대 경로)
    /// - Throws: 이미지 저장 실패 시 에러
    func saveProfileImage(_ image: UIImage) throws -> String {
        // 1. 기존 이미지 삭제
        deleteProfileImageIfExists()
        
        // 2. 이미지를 JPEG 데이터로 변환
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            throw ProfileImageError.imageConversionFailed
        }
        
        // 3. 파일 시스템에 저장
        do {
            try imageData.write(to: profileImageURL)
            Logger.data.info("프로필 이미지 저장 성공: \(self.profileImageURL.path)")
            // 절대 경로 대신 파일명만 반환
            return profileImageFileName
        } catch {
            Logger.data.error("프로필 이미지 저장 실패: \(error.localizedDescription)")
            throw ProfileImageError.saveFailed(error)
        }
    }
    
    /// 저장된 프로필 이미지 로드
    /// - Returns: 저장된 UIImage 또는 nil
    func loadProfileImage() -> UIImage? {
        guard fileManager.fileExists(atPath: profileImageURL.path) else {
            Logger.data.info("저장된 프로필 이미지가 없습니다.")
            return nil
        }
        
        guard let imageData = try? Data(contentsOf: profileImageURL),
              let image = UIImage(data: imageData) else {
            Logger.data.error("프로필 이미지 로드 실패")
            return nil
        }
        
        Logger.data.info("프로필 이미지 로드 성공")
        return image
    }
    
    /// URL 경로 문자열로 이미지 로드
    /// - Parameter urlString: 이미지 파일명 또는 경로 문자열
    /// - Returns: UIImage 또는 nil
    func loadProfileImage(from urlString: String) -> UIImage? {
        guard !urlString.isEmpty else { return nil }
        
        // urlString이 파일명만 있는 경우와 전체 경로인 경우를 모두 처리
        let fileURL: URL
        if urlString.contains("/") {
            // 전체 경로인 경우 (기존 데이터 호환성)
            fileURL = URL(fileURLWithPath: urlString)
        } else {
            // 파일명만 있는 경우 (새로운 방식)
            fileURL = profileImageDirectory.appendingPathComponent(urlString)
        }
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            Logger.data.warning("해당 경로에 이미지가 없습니다: \(fileURL.path)")
            return nil
        }
        
        guard let imageData = try? Data(contentsOf: fileURL),
              let image = UIImage(data: imageData) else {
            Logger.data.error("이미지 로드 실패: \(fileURL.path)")
            return nil
        }
        
        return image
    }
    
    /// 프로필 이미지 삭제
    func deleteProfileImage() throws {
        guard fileManager.fileExists(atPath: profileImageURL.path) else {
            Logger.data.info("삭제할 프로필 이미지가 없습니다.")
            return
        }
        
        do {
            try fileManager.removeItem(at: profileImageURL)
            Logger.data.info("프로필 이미지 삭제 성공")
        } catch {
            Logger.data.error("프로필 이미지 삭제 실패: \(error.localizedDescription)")
            throw ProfileImageError.deleteFailed(error)
        }
    }
    
    /// 프로필 이미지 파일 경로 반환
    /// - Returns: 파일명 (상대 경로)
    func getProfileImagePath() -> String {
        return profileImageFileName
    }
    
    /// 프로필 이미지 존재 여부 확인
    /// - Returns: 파일 존재 여부
    func hasProfileImage() -> Bool {
        return fileManager.fileExists(atPath: profileImageURL.path)
    }
    
    // MARK: - Private Methods
    
    /// 기존 프로필 이미지가 있으면 삭제
    private func deleteProfileImageIfExists() {
        guard fileManager.fileExists(atPath: profileImageURL.path) else { return }
        
        do {
            try fileManager.removeItem(at: profileImageURL)
            Logger.data.info("기존 프로필 이미지 삭제 완료")
        } catch {
            Logger.data.warning("기존 프로필 이미지 삭제 실패: \(error.localizedDescription)")
        }
    }
}

// MARK: - Error Definition
enum ProfileImageError: LocalizedError {
    case imageConversionFailed
    case saveFailed(Error)
    case deleteFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "이미지 변환에 실패했습니다."
        case .saveFailed(let error):
            return "이미지 저장에 실패했습니다: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "이미지 삭제에 실패했습니다: \(error.localizedDescription)"
        }
    }
}
