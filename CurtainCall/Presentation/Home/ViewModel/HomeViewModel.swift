//
//  HomeViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 9/27/25.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel: BaseViewModel {
    
    // MARK: - Properties
    private let networkManager = NetworkManager.shared
    private let disposeBag = DisposeBag()
    
    // MARK: - Input / Output
    struct Input {
        
    }
    
    struct Output {
        let boxOfficeList: Driver<[BoxOffice]>
    }
    
    // MARK: - Stream
    private let boxOfficeListRelay = BehaviorRelay<[BoxOffice]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<NetworkError>()
    
    // MARK: - Init
    override init() {
        super.init()
        
        loadInitialData()
    }
    
    func transform(input: Input) -> Output {
        
        return Output(
            boxOfficeList: boxOfficeListRelay.asDriver()
        )
    }
    
    private func loadInitialData() {
        let today = Date()
        let yesterday = today.yesterday
        
        let startDate = yesterday.toKopisAPIFormatt
        let endDate = yesterday.toKopisAPIFormatt
        
        loadBoxOffice(startDate: startDate, endDate: endDate, category: .musical, area: .seoul)
    }
    
    func loadBoxOffice(startDate: String, endDate: String, category: CategoryCode?, area: AreaCode?) {
        isLoadingRelay.accept(true)
        
        CustomObservable.request(.boxOffice(startDate: startDate, endDate: endDate, category: category, area: area), responseType: BoxOfficeResponseDTO.self)
            .subscribe(with: self) { owner, response in
                owner.isLoadingRelay.accept(false)
                let boxOffices = BoxOfficeMapper.map(from: response.boxofs.boxof)
                owner.boxOfficeListRelay.accept(boxOffices)
            } onFailure: { owner, error in
                owner.isLoadingRelay.accept(false)
                if let networkError = error as? NetworkError {
                    owner.errorRelay.accept(networkError)
                }
            }
            .disposed(by: disposeBag)
    }
}
