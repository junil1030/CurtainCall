//
//  DIContainer+Factory.swift
//  CurtainCall
//
//  Created by 서준일 on 10/27/25.
//

import Foundation

// MARK: - ViewModel Factory
extension DIContainer {
    
    // MARK: - Home
     func makeHomeViewModel() -> HomeViewModel {
         let getUserProfileuseCase = resolve(GetUserProfileUseCase.self)
         return HomeViewModel(getUserProfileUseCase: getUserProfileuseCase)
     }
    
    // MARK: - Search
     func makeSearchViewModel() -> SearchViewModel {
         let addRecentSearchUseCase = resolve(AddRecentSearchUseCase.self)
         let getRecentSearchesUseCase = resolve(GetRecentSearchesUseCase.self)
         let deleteRecentSearchUseCase = resolve(DeleteRecentSearchUseCase.self)
         let clearAllRecentSearchesUseCase = resolve(ClearAllRecentSearchesUseCase.self)
         
         return SearchViewModel(
             addRecentSearchUseCase: addRecentSearchUseCase,
             getRecentSearchesUseCase: getRecentSearchesUseCase,
             deleteRecentSearchUseCase: deleteRecentSearchUseCase,
             clearAllRecentSearchesUseCase: clearAllRecentSearchesUseCase
         )
     }
    
    // MARK: - Detail
    func makeDetailViewModel(performanceID: String) -> DetailViewModel {
        let toggleFavoriteUseCase = resolve(ToggleFavoriteUseCase.self)
        let checkFavoriteUseCase = resolve(CheckFavoriteStatusUseCase.self)
        
        return DetailViewModel(
            performanceID: performanceID,
            toggleFavoriteUseCase: toggleFavoriteUseCase,
            checkFavoriteStatusUseCase: checkFavoriteUseCase
        )
    }
    
    // MARK: - Favorite
    func makeFavoriteViewModel() -> FavoriteViewModel {
        let fetchFavoritesUseCase = resolve(FetchFavoritesUseCase.self)
        let removeFavoriteUseCase = resolve(RemoveFavoriteUseCase.self)
        let getMonthlyFavoriteCountUseCase = resolve(GetMonthlyFavoriteCountUseCase.self)
        let getFavoriteStatisticsUseCase = resolve(GetFavoriteStatisticsUseCase.self)
        
        return FavoriteViewModel(
            fetchFavoritesUseCase: fetchFavoritesUseCase,
            removeFavoriteUseCase: removeFavoriteUseCase,
            getMonthlyFavoriteCountUseCase: getMonthlyFavoriteCountUseCase,
            getFavoriteStatisticsUseCase: getFavoriteStatisticsUseCase
        )
    }
    
    // MARK: - Record
    func makeRecordListViewModel() -> RecordListViewModel {
        let getAllViewingRecordsUseCase = resolve(GetAllViewingRecordsUseCase.self)
        return RecordListViewModel(getAllViewingRecordsUseCase: getAllViewingRecordsUseCase)
    }
    
    func makeWriteRecordViewModel(mode: WriteRecordMode) -> WriteRecordViewModel {
        let addViewingRecordUseCase = resolve(AddViewingRecordUseCase.self)
        let getViewingRecordByIdUseCase = resolve(GetViewingRecordByIdUseCase.self)
        let updateViewingRecordUseCase = resolve(UpdateViewingRecordUseCase.self)
        
        return WriteRecordViewModel(
            mode: mode,
            addViewingRecordUseCase: addViewingRecordUseCase,
            getViewingRecordByIdUseCase: getViewingRecordByIdUseCase,
            updateViewingRecordUseCase: updateViewingRecordUseCase
        )
    }
    
    // MARK: - More
    func makeMoreViewModel() -> MoreViewModel {
        let getUserProfileUseCase = resolve(GetUserProfileUseCase.self)
        return MoreViewModel(getUserProfileUseCase: getUserProfileUseCase)
    }
    
    func makeProfileEditViewModel() -> ProfileEditViewModel {
        let getUserProfileUseCase = resolve(GetUserProfileUseCase.self)
        let updateProfileImageUseCase = resolve(UpdateProfileImageUseCase.self)
        let updateNicknameUseCase = resolve(UpdateNicknameUseCase.self)
        
        return ProfileEditViewModel(
            getUserProfileUseCase: getUserProfileUseCase,
            updateProfileImageUseCase: updateProfileImageUseCase,
            updateNicknameUseCase: updateNicknameUseCase
        )
    }
    
    // MARK: - Stats
    func makeStatsViewModel() -> StatsViewModel {
        let fetchStatsUseCase = resolve(FetchStatsUseCase.self)
        return StatsViewModel(useCase: fetchStatsUseCase)
    }
}
