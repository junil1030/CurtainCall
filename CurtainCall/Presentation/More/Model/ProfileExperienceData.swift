//
//  ProfileExperienceData.swift
//  CurtainCall
//
//  Created by 서준일 on 10/1/25.
//

import Foundation

struct ProfileExperienceData {
    let nickname: String
    let subtitle: String
    let level: Int
    let currentExp: Int
    let maxExp: Int
    
    var remainingExp: Int {
        return maxExp - currentExp
    }
}
