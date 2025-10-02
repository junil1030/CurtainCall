//
//  ViewingRecordRepositoryProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation
import RealmSwift

protocol ViewingRecordRepositoryProtocol {
    // Create
    func addRecord(_ record: ViewingRecord) throws
    
    // Read
    func getRecords() -> [ViewingRecord]
    func getRecordsByDate(from: Date, to: Date) -> [ViewingRecord]
    func getRecordsByPerformance(performanceId: String) -> [ViewingRecord]
    func getRecordCount() -> Int
    func getRecord(by id: ObjectId) -> ViewingRecord?
    
    // Update
    func updateRecord(_ record: ViewingRecord) throws
    func updateRating(id: ObjectId, rating: Int) throws
    func updateMemo(id: ObjectId, memo: String) throws
    
    // Delete
    func deleteRecord(id: ObjectId) throws
    func deleteAllRecords() throws
    
    // Statistics
    func getStatistics() -> ViewingStatistics
}
