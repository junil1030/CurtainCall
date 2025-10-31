//
//  GetUserStatisticsUseCase.swift
//  CurtainCall
//
//  Created by 서준일 on 10/27/25.
//

import Foundation

final class GetUserStatisticsUseCase: UseCase {
    
    // MARK: - Typealias
    typealias Input = Void
    typealias Output = UserStatistics
    
    // MARK: - Properties
    private let userRepository: UserRepositoryProtocol
    private let viewingRecordRepository: ViewingRecordRepositoryProtocol
    private let favoriteRepository: FavoriteRepositoryProtocol
    
    // MARK: - Init
    init(
        userRepository: UserRepositoryProtocol,
        viewingRecordRepository: ViewingRecordRepositoryProtocol,
        favoriteRepository: FavoriteRepositoryProtocol
    ) {
        self.userRepository = userRepository
        self.viewingRecordRepository = viewingRecordRepository
        self.favoriteRepository = favoriteRepository
    }
    
    // MARK: - Execute
    func execute(_ input: Void) -> UserStatistics {
        guard let user = userRepository.getUser() else {
            return UserStatistics(
                nickname: "닉네임",
                joinedDays: 0,
                totalViewingCount: 0,
                totalFavoriteCount: 0
            )
        }
        
        let joinedDays = Calendar.current.dateComponents([.day], from: user.createdAt, to: Date()).day ?? 0
        
        let totalViewingCount = viewingRecordRepository.getRecordCount()
        let totalFavoriteCount = favoriteRepository.getFavoriteCount()
        
        return UserStatistics(
            nickname: user.nickname,
            joinedDays: joinedDays,
            totalViewingCount: totalViewingCount,
            totalFavoriteCount: totalFavoriteCount
        )
    }
}

// MARK: - Statistics Model
struct UserStatistics {
    let nickname: String
    let joinedDays: Int
    let totalViewingCount: Int
    let totalFavoriteCount: Int
    
    var level: Int {
        // 레벨 계산 로직: 관람 기록 * 10 + 찜 개수
        let totalExp = totalViewingCount * 10 + totalFavoriteCount
        return max(1, totalExp / 30) // 30 경험치당 1레벨
    }
    
    var currentExp: Int {
        let totalExp = totalViewingCount * 10 + totalFavoriteCount
        return totalExp % 30
    }
    
    var maxExp: Int {
        return 30
    }
    
    var experienceData: ProfileExperienceData {
        return ProfileExperienceData(
            nickname: nickname,
            subtitle: "커튼콜과 함께한지 \(joinedDays)일",
            level: level,
            currentExp: currentExp,
            maxExp: maxExp
        )
    }
}
