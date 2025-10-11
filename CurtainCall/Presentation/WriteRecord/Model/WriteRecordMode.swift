//
//  WriteRecordMode.swift
//  CurtainCall
//
//  Created by 서준일 on 10/11/25.
//

import Foundation

enum WriteRecordMode {
    case create(performanceDetail: PerformanceDetail)
    case edit(recordId: String)
}
