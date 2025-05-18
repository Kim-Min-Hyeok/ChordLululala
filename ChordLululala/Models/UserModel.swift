//
//  UserModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 2/25/25.
//

import Foundation

struct UserModel: Identifiable, Equatable {
    var id: String
    var providerId: String?
    var name: String?
    var email: String?
    var profileImageURL: String?
}
