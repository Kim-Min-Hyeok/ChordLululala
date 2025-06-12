//
//  UserModel.swift
//  ChordLululala
//
//  Created by Minhyeok Kim on 6/12/25.
//

import Foundation

struct UserModel: Identifiable, Equatable {
    var id: String
    var providerId: String?
    var name: String?
    var email: String?
    var profileImageURL: String?
}
