//
//  UseCaseProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/3/25.
//

import Foundation

protocol UseCase {
    associatedtype Input
    associatedtype Output
    
    func execute(_ input: Input) -> Output
}
