//
//  PatriciaTrie+Utils.swift
//  
//
//  Created by Richard Perry on 9/24/24.
//

import Foundation

internal extension SwiftTrie {
    
    func firstDifferentBitBetween(firstString: String, secondString: String) -> Int {
        var i: Int = -1
        // If both strings are zero (unsupported feature) then return 0
        if firstString.count == 0 && secondString.count == 0 {
            return 0
        }
        let firstUtf = firstString.utf16
        let firstIndex = firstUtf.startIndex
        let secondUtf = secondString.utf16
        let secondIndex = secondUtf.startIndex
        var firstChar: UInt16 = 0
        var secondChar: UInt16 = 0
        
        
        while firstChar == secondChar {
            i += 1
            // Get charactet at the i-th location in the first string
            if firstUtf.count <= i {
                firstChar = 0
            } else {
                let firstCharIndex = firstUtf.index(firstIndex, offsetBy: i)
                firstChar = firstUtf[firstCharIndex]
            }
            // Get charactet at the i-th location in the second string
            if secondUtf.count <= i {
                secondChar = 0
            } else {
                let secondCharIndex = secondUtf.index(secondIndex, offsetBy: i)
                secondChar = secondUtf[secondCharIndex]
            }
            // If either character is null then we found the index of the different bit
            if firstChar == 0 || secondChar == 0 {
                break
            }
        }
        
        if firstChar != secondChar {
            // Location in bits of the location of first different bit multiplied by the number of bits the character has (utf-16 is 16 bits)
            // and then add the number of zeroes of the bitwise or of the characters
            return i * STRINGBITS + numberOfLeadingZeroesInBinary(value: firstChar ^ secondChar)
        }
        // If strings match then return -1
        return -1
    }
    
    func numberOfLeadingZeroesInBinary(value: UInt16) -> Int {
        var numZeroes: Int = 0
        // Loop through the value until a 1 is hit, determining how many zero bits are in the front
        for num in stride(from: 15, to: 0, by: -1) {
            // Use bitwise and with 1 since if the bit location is 0 then the value will also be 0
            if value & (1 << num) == 0 {
                numZeroes += 1
            } else {
                break
            }
        }
        return numZeroes
    }
    
    // Checks if the bit at the given index is 0 or 1
    func isBitSet(key: String, bitIndex: Int, lengthInBits: Int) -> Bool {
        let stringView = key.utf16
        if bitIndex >= lengthInBits {
            return false
        }
        
        // Character position in node's string
        let index = bitIndex / STRINGBITS
        // Bit position for character
        let mod = bitIndex % STRINGBITS
        // Mask to determine whether or not to use left child or right child
        let locMask = MASK >> mod
        let charIndex = stringView.index(stringView.startIndex, offsetBy: index)
        let wantedChar = stringView[charIndex]
        return Int(wantedChar) & locMask != 0
    }
}
