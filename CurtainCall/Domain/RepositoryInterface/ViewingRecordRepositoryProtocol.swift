//
//  ViewingRecordRepositoryProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation
import RealmSwift

protocol ViewingRecordRepositoryProtocol {
    func addRecord(_ record: ViewingRecord) throws
    func updateRecord(_ record: ViewingRecord) throws
    func deleteRecord(id: ObjectId) throws
    func getRecords() -> [ViewingRecord]
    func getRecordsByDate(from: Date, to: Date) -> [ViewingRecord]
    func getRecordCount() -> Int
}
