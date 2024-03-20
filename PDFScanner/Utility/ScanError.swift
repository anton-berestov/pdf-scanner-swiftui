//
//  ScanError.swift
//  FolderCreate
//
//  Created by Anton Berestov on 19.03.24.
//

import Foundation

// https://developer.apple.com/documentation/swift/error
struct ScanError: Error {
    let id = UUID()
}

extension ScanError: Equatable {
    static func ==(lhs: ScanError, rhs: ScanError) -> Bool {
        return lhs.id == rhs.id
    }
}
