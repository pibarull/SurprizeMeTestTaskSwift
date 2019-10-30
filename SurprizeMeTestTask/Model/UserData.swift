//
//  User.swift
//  SurprizeMeTestTask
//
//  Created by Илья Ершов on 28/10/2019.
//  Copyright © 2019 Ilia Ershov. All rights reserved.
//

import Foundation

struct UserData : Codable {
    let data: Data
    
    struct Data: Codable {
    
        let id: UInt
        let email: String
        let firstName: String
        let lastName: String
        let nickname: String
        let avatar: String
        let isSuperuser: Bool
        let isPasswordSet : Bool
        let isSocialSet: Bool
        let isPartner: Bool
        let isSales: Bool
        let permissions: [Int]
        let locale: String
        let createdAt: Int
        let favoriteProducts: [Int]
        let isHijacked: Bool
        let client : Client
        
        struct Client : Codable {
            let name: String
            let maxDownloads: UInt
            let downloads: UInt
        }
    }
    
   
}
