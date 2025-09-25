//
//  BaseViewModel.swift
//  CurtainCall
//
//  Created by 서준일 on 9/25/25.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

class BaseViewModel: ViewModelType {
    struct Input {}
    struct Output {}
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
