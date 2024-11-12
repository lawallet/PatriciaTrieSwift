//
//  SwiftTrie.swift
//
//
//  Created by Richard Perry on 9/24/24.
//

import Foundation

public class SwiftTrie {
    internal let STRINGBITS: Int = 16
    // 32768 (1000000000000000 in binary)
    internal let MASK = 0x8000
    private var root: PatriciaTrieNode
    public var count: Int64 = 0
    
    public init() {
        self.root = PatriciaTrieNode(key: "")
        self.root.left = self.root
        self.count = 0
    }
    
    public func insertString(_ string: String) -> Bool {
        if string.count < 1 {
            return false
        }
        let lengthInBits = string.count * STRINGBITS
        
        // Find the string that's the closest to the string to insert
        let nearest = getNearestNodeForKey(string, lengthInBits: lengthInBits)
        let nearestString = nearest.key
        // Duplicates aren't allowed
        if nearestString == string {
            return false
        }
        let firstDifferentBit = firstDifferentBitBetween(firstString: nearestString, secondString: string)
        var parent = root
        var child: PatriciaTrieNode = root.left
        
        // Determine location in the tree to add the new node too
        while child.indexBit > parent.indexBit && child.indexBit < firstDifferentBit {
            let isSet = isBitSet(key: string, bitIndex: child.indexBit, lengthInBits: lengthInBits)
            parent = child
            if !isSet {
                child = child.left
            } else {
                child = child.right
            }
        }

        let newNode = PatriciaTrieNode(key: string, indexBit: firstDifferentBit)
        // Determine location to place replacement child node, this new node will be used as the replacement if the key of childNode is deleted
        var bitSet = isBitSet(key: string, bitIndex: firstDifferentBit, lengthInBits: lengthInBits)
        if !bitSet {
            newNode.left = newNode
            newNode.right = child
        } else {
            newNode.left = child
            newNode.right = newNode
        }
        // Determine where to place new Node
        bitSet = isBitSet(key: string, bitIndex: parent.indexBit, lengthInBits: lengthInBits)
        let parIdent = ObjectIdentifier(parent)
        let rootIdent = ObjectIdentifier(root)
        if !bitSet || parIdent == rootIdent {
            parent.left = newNode
        } else {
            parent.right = newNode
        }
        
        count += 1
        return true
    }
    
    public func deleteString(_ string: String) -> Bool {
        if count == 0 {
            return false
        }
        
        let lengthInBits = string.count * STRINGBITS
        // Is the key currently in the trie?
        let nodePath = getNearestNodeAndAncestorsForKey(string, lengthInBits: lengthInBits, forDelete: true)
        guard let grandParent: PatriciaTrieNode = nodePath.replacingParent, let parent: PatriciaTrieNode = nodePath.replacingNode else {
            return false
        }
        let nodeToDelete = nodePath.found
        var bitSet = false
        if nodeToDelete.key == string {
            // Should always be the case if the node was found, but never hurts to check
            guard let trueParent = nodePath.foundParent else {
                return false
            }
            // Does the Node have have less than 2 children?
            if nodeToDelete == parent {
                // Since nodes loop back on themselves when added, this means that there is only one child so replace the deleted node with its only child
                var replacementNode: PatriciaTrieNode
                bitSet = isBitSet(key: string, bitIndex: nodeToDelete.indexBit, lengthInBits: lengthInBits)
                if !bitSet {
                    replacementNode = nodeToDelete.right
                } else {
                    replacementNode = nodeToDelete.left
                }
                bitSet = isBitSet(key: string, bitIndex: trueParent.indexBit, lengthInBits: lengthInBits)
                if !bitSet {
                    trueParent.left = replacementNode
                } else {
                    trueParent.right = replacementNode
                }
                nodeToDelete.left = nil
                nodeToDelete.right = nil
            } else {
                //Node has two children
                var replacementNode: PatriciaTrieNode
                bitSet = isBitSet(key: string, bitIndex: parent.indexBit, lengthInBits: lengthInBits)
                if !bitSet && parent != root {
                    replacementNode = parent.right
                } else {
                    replacementNode = parent.left
                }
                bitSet = isBitSet(key: string, bitIndex: grandParent.indexBit, lengthInBits: lengthInBits)
                if !bitSet {
                    grandParent.left = replacementNode
                } else {
                    grandParent.right = replacementNode
                }
                bitSet = isBitSet(key: string, bitIndex: trueParent.indexBit, lengthInBits: lengthInBits)
                if !bitSet {
                    trueParent.left = parent
                } else {
                    trueParent.right = parent
                }
                parent.left = nodeToDelete.left
                parent.right = nodeToDelete.right
                parent.indexBit = nodeToDelete.indexBit
            }
            count -= 1
            return true
        }
        return false
    }
    
    public func findNodeForString(_ string: String) -> PatriciaTrieNode? {
        let foundNodes = searchForKey(string, getAllMatches: false)
        return foundNodes.count > 0 ? foundNodes.first! : nil
    }
    
    public func getAllStringsForPrefix(_ prefix: String) -> [String] {
        return searchForKey(prefix, getAllMatches: true).compactMap({$0.key})
    }
    
    private func getNearestNodeForKey(_ key: String, lengthInBits: Int) -> PatriciaTrieNode {
        return getNearestNodeAndAncestorsForKey(key, lengthInBits: lengthInBits).found
    }
    
    private func searchForKey(_ key: String, getAllMatches: Bool) -> [PatriciaTrieNode] {
        let lengthInBits = key.count * STRINGBITS
        var foundValues: [PatriciaTrieNode] = []
        let closest = getNearestNodeForKey(key, lengthInBits: lengthInBits)
        let matchFound = getAllMatches ? closest.key.startsWithString(key) : closest.key == key
        if matchFound {
            foundValues.append(closest)
            if getAllMatches {
                foundValues.append(contentsOf: findOtherNodesMatchingString(key, from: closest))
            }
        }
        return foundValues
    }
    
    private func findOtherNodesMatchingString(_ key: String, from node: PatriciaTrieNode) -> [PatriciaTrieNode] {
        var otherValues: [PatriciaTrieNode] = []
        var unseenNodes: [PatriciaTrieNode] = []
        if node.left != node {
            unseenNodes.append(node.left)
        }
        if node.right != node {
            unseenNodes.append(node.right)
        }
        
        var seenNodes: Set<String> = [node.key]
        while unseenNodes.count != 0 {
            let curr = unseenNodes.removeLast()
            if curr.key.starts(with: key) && false == seenNodes.contains(curr.key) {
                otherValues.append(curr)
            } else {
                continue
            }
            seenNodes.insert(curr.key)
            if curr.left != curr {
                unseenNodes.append(curr.left)
            }
            if curr.right != curr {
                unseenNodes.append(curr.right)
            }
        }
        return otherValues
    }
    
    private func getNearestNodeAndAncestorsForKey(_ key: String, lengthInBits: Int, forDelete: Bool = false) -> FoundNodes {
        let rootIdent = ObjectIdentifier(root)
        var grandParent: PatriciaTrieNode = root
        var parent: PatriciaTrieNode = root
        var currentNode: PatriciaTrieNode! = root.left
        var foundParent: PatriciaTrieNode?
        var bitSet = false
        
        while (currentNode.indexBit > parent.indexBit) {
            if currentNode.key == key {
                if forDelete {
                    // This loop will terminate when the loopback of the node with the key is found so a reference to this is required when deleting
                    foundParent = parent
                } else {
                    // If all we're doing is searching for a key then finish 'early' if it's found
                    break
                }
            }

            bitSet = isBitSet(key: key, bitIndex: currentNode.indexBit, lengthInBits: lengthInBits)
            grandParent = parent
            parent = currentNode
            let parIdent = ObjectIdentifier(parent)
            if !bitSet || parIdent == rootIdent {
                if currentNode.left.key == currentNode.key {
                    foundParent = grandParent
                }
                currentNode = currentNode.left
            } else {
                if currentNode.right.key == currentNode.key {
                    foundParent = grandParent
                }
                currentNode = currentNode.right
            }
        }
        let retVal: FoundNodes
        if forDelete {
            retVal = FoundNodes(found: currentNode, replacingNode: parent, replacingParent: grandParent, foundParent: foundParent)
        } else {
            retVal = FoundNodes(found: currentNode)
        }
        return retVal
    }
    
}

private struct FoundNodes {
    var found: PatriciaTrieNode
    var replacingNode: PatriciaTrieNode?
    var replacingParent: PatriciaTrieNode?
    var foundParent: PatriciaTrieNode?
}
