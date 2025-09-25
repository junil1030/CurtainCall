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
    
    func tarnsform(input: Input) -> Output
}

class BaseViewModel: ViewModelType {
    struct Input {}
    struct Output {}
    
    func tarnsform(input: Input) -> Output {
        return Output()
    }
}
