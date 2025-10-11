//
//  RecordSection.swift
//  CurtainCall
//
//  Created by 서준일 on 10/10/25.
//

import Foundation

enum RecordSection: Hashable {
    case main
}

enum RecordItem: Hashable {
    case record(ViewingRecordDTO)
}
