//
//  RealmProvider.swift
//  CurtainCall
//
//  Created by 서준일 on 10/27/25.
//

import Foundation
import RealmSwift

// Thread-safe를 위해 매번 새로운 Realm 인스턴스를 생성
protocol RealmProvider {
    
    func realm() throws -> Realm
    func compact()
    func initializeDefaultUser() throws
    func printDebugInfo()
}
