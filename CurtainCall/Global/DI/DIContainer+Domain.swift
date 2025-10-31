//
//  DIContainer+Domain.swift
//  CurtainCall
//
//  Created by 서준일 on 10/27/25.
//

import Foundation
import OSLog

// MARK: - Domain Layer
extension DIContainer {
    
    // Domain 계층 의존성 등록 (UseCase)
    func registerUseCases() {
        Logger.data.info("🔧 UseCases 등록 시작")
        
        // MARK: - User
        register(GetUserProfileUseCase.self) {
            Logger.data.info("👤 GetUserProfileUseCase 생성 시작")
            let repository = self.resolve(UserRepositoryProtocol.self)
            Logger.data.info("👤 GetUserProfileUseCase 생성 완료")
            return GetUserProfileUseCase(repository: repository)
        }
        
        register(GetUserStatisticsUseCase.self) {
            let userRepository = self.resolve(UserRepositoryProtocol.self)
            let viewingRecordRepository = self.resolve(ViewingRecordRepositoryProtocol.self)
            let favoriteRepository = self.resolve(FavoriteRepositoryProtocol.self)
            return GetUserStatisticsUseCase(
                userRepository: userRepository,
                viewingRecordRepository: viewingRecordRepository,
                favoriteRepository: favoriteRepository
            )
        }
        
        register(UpdateNicknameUseCase.self) {
            let repository = self.resolve(UserRepositoryProtocol.self)
            return UpdateNicknameUseCase(repository: repository)
        }
        
        register(UpdateProfileImageUseCase.self) {
            let repository = self.resolve(UserRepositoryProtocol.self)
            let imageStorage = self.resolve(ImageStorageProtocol.self)
            return UpdateProfileImageUseCase(repository: repository, imageStorage: imageStorage)
        }
        
        // MARK: - Favorite
        register(CheckFavoriteStatusUseCase.self) {
            let repository = self.resolve(FavoriteRepositoryProtocol.self)
            return CheckFavoriteStatusUseCase(repository: repository)
        }
        
        register(CheckMultipleFavoriteStatusUseCase.self) {
            let repository = self.resolve(FavoriteRepositoryProtocol.self)
            return CheckMultipleFavoriteStatusUseCase(repository: repository)
        }
        
        register(FetchFavoritesUseCase.self) {
            let repository = self.resolve(FavoriteRepositoryProtocol.self)
            return FetchFavoritesUseCase(repository: repository)
        }
        
        register(GetFavoriteStatisticsUseCase.self) {
            let repository = self.resolve(FavoriteRepositoryProtocol.self)
            return GetFavoriteStatisticsUseCase(repository: repository)
        }
        
        register(GetMonthlyFavoriteCountUseCase.self) {
            let repository = self.resolve(FavoriteRepositoryProtocol.self)
            return GetMonthlyFavoriteCountUseCase(repository: repository)
        }
        
        register(RemoveFavoriteUseCase.self) {
            let repository = self.resolve(FavoriteRepositoryProtocol.self)
            return RemoveFavoriteUseCase(repository: repository)
        }
        
        register(ToggleFavoriteUseCase.self) {
            let repository = self.resolve(FavoriteRepositoryProtocol.self)
            return ToggleFavoriteUseCase(repository: repository)
        }
        
        // MARK: - Viewing Record
        register(AddViewingRecordUseCase.self) {
            let repository = self.resolve(ViewingRecordRepositoryProtocol.self)
            return AddViewingRecordUseCase(repository: repository)
        }
        
        register(GetAllViewingRecordsUseCase.self) {
            let repository = self.resolve(ViewingRecordRepositoryProtocol.self)
            return GetAllViewingRecordsUseCase(repository: repository)
        }
        
        register(GetViewingRecordByIdUseCase.self) {
            let repository = self.resolve(ViewingRecordRepositoryProtocol.self)
            return GetViewingRecordByIdUseCase(repository: repository)
        }
        
        register(UpdateViewingRecordUseCase.self) {
            let repository = self.resolve(ViewingRecordRepositoryProtocol.self)
            return UpdateViewingRecordUseCase(repository: repository)
        }
        
        // MARK: - Recent Search
        register(AddRecentSearchUseCase.self) {
            let repository = self.resolve(RecentSearchRepositoryProtocol.self)
            return AddRecentSearchUseCase(repository: repository)
        }
        
        register(ClearAllRecentSearchesUseCase.self) {
            let repository = self.resolve(RecentSearchRepositoryProtocol.self)
            return ClearAllRecentSearchesUseCase(repository: repository)
        }
        
        register(DeleteRecentSearchUseCase.self) {
            let repository = self.resolve(RecentSearchRepositoryProtocol.self)
            return DeleteRecentSearchUseCase(repository: repository)
        }
        
        register(GetRecentSearchesUseCase.self) {
            let repository = self.resolve(RecentSearchRepositoryProtocol.self)
            return GetRecentSearchesUseCase(repository: repository)
        }
        
        // MARK: - Stat
        register(FetchStatsUseCase.self) {
            let repository = self.resolve(ViewingRecordRepositoryProtocol.self)
            return FetchStatsUseCase(repository: repository)
        }
        
        Logger.data.info("✅ UseCases 등록 완료")
    }
}
