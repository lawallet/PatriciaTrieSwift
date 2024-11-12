//
//  File.swift
//  
//
//  Created by Richard Perry on 9/27/24.
//

import Foundation

extension String {
    func startsWithString(_ string: String) -> Bool {
        do {
            let regex = try Regex(string)
            return try regex.prefixMatch(in: self) != nil
        } catch {
            return false
        }
    }
}
