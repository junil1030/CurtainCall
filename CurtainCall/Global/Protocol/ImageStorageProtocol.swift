//
//  ImageStorageProtocol.swift
//  CurtainCall
//
//  Created by 서준일 on 10/27/25.
//

import UIKit

protocol ImageStorageProtocol {
    
    func saveProfileImage(_ image: UIImage) throws -> String
    func loadProfileImage() -> UIImage?
    func loadProfileImage(from urlString: String) -> UIImage?
    
    func deleteProfileImage() throws
    
    func getProfileImagePath() -> String
    func hasProfileImage() -> Bool
}
