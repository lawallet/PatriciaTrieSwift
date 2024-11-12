//
//  PatriciaTrieNode.swift
//  
//
//  Created by Richard Perry on 9/24/24.
//

import Foundation

public class PatriciaTrieNode: Equatable, Hashable {
    
    public static func == (lhs: PatriciaTrieNode, rhs: PatriciaTrieNode) -> Bool {
        return lhs.key == rhs.key && lhs.indexBit == rhs.indexBit
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(indexBit)
    }
    
    public var key: String
    public var left: PatriciaTrieNode!
    public var right: PatriciaTrieNode!
    internal var indexBit: Int
    
    internal init(key: String, left: PatriciaTrieNode? = nil, right: PatriciaTrieNode? = nil, indexBit: Int = 0) {
        self.key = key
        self.left = left
        self.right = right
        self.indexBit = indexBit
    }
    
}
