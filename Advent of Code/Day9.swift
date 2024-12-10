//
//  Day9.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-09.
//  SPDX-License-Identifier: MIT
//

public struct Day9: AdventDay {
    
    enum NodeType: Equatable {
        case used(Int)
        case empty
        
        var isEmpty: Bool {
            switch self {
            case .empty: true
            default: false
            }
        }
        
        var isUsed: Bool {
            switch self {
            case .used(_): true
            default: false
            }
        }
    }
    
    class Node: CustomStringConvertible {
        var previous: Node? = nil
        var next: Node? = nil
        var length: Int = 0
        var type: NodeType = .empty
        
        var description: String {
            switch type {
            case .empty: String(repeating: ".", count: length)
            case .used(let id): String(repeating: String(id), count: length)
            }
        }
        
        static func empty(length: Int) -> Node {
            let node = Node()
            node.length = length
            node.type = .empty
            
            return node
        }
        
        static func used(id: Int, length: Int) -> Node {
            let node = Node()
            node.length = length
            node.type = .used(id)
            
            return node
        }
    }
    
    class Filesystem {
        
        var head: Node?
        var tail: Node?
        
        init(data: String) {
            for (index, letter) in data.enumerated() {
                let length = letter.wholeNumberValue!
                
                guard length > 0 else { continue }
                
                let node = if index % 2 == 0 {
                    Node.used(id: index / 2, length: length)
                } else {
                    Node.empty(length: length)
                }
                
                if index == 0 {
                    head = node
                    tail = node
                } else {
                    tail?.next = node
                    node.previous = tail
                    
                    tail = node
                }
            }
            
            let empty = Node.empty(length: 0)
            
            tail?.next = empty
            empty.previous = tail
            tail = empty
        }
        
        var checksum: Int {
            var index = 0
            var currentNode = head
            var sum = 0
            
            while let node = currentNode {
                if case .used(let id) = node.type {
                    for offset in (0 ..< node.length) {
                        sum += id * (index + offset)
                    }
                }
                
                index += node.length
                currentNode = node.next
            }
            
            return sum
        }
        
        func compact() {
            var lhsNode = head
            var rhsNode = tail
            
            while true {
                while lhsNode != nil, lhsNode!.type.isUsed { lhsNode = lhsNode!.next }
                while rhsNode != nil, rhsNode!.type.isEmpty { rhsNode = rhsNode!.previous }
                
                guard let emptyNode = lhsNode, let usedNode = rhsNode else { return }
                guard emptyNode !== tail else { return }
                
                // Increment the empty space at the end
                guard let finalEmptyNode = tail, finalEmptyNode.type == .empty else { fatalError("Last node is not empty") }
                finalEmptyNode.length += 1
                
                // Decrement the used node
                guard case .used(let usedId) = usedNode.type else { fatalError("RHS was not a used node") }
                usedNode.length -= 1
                
                // If the used node is gone, remove it
                if usedNode.length == 0 {
                    remove(node: usedNode)
                    rhsNode = usedNode.previous
                }
                
                // If the prior empty node matches IDs, increment it, otherwise inject a new node
                if let previousNode = emptyNode.previous, case .used(let previousId) = previousNode.type, previousId == usedId {
                    previousNode.length += 1
                } else {
                    let newNode = Node.used(id: usedId, length: 1)
                    insert(node: newNode, before: emptyNode)
                }
                
                // Decrement or remove the empty node
                emptyNode.length -= 1
                
                if emptyNode.length == 0 {
                    remove(node: emptyNode)
                    lhsNode = emptyNode.next
                }
            }
        }
        
        func compactBetter() {
            var rhsNode = tail
            
            while true {
                // Get the next used chunk to move
                while rhsNode != nil, rhsNode!.type.isEmpty { rhsNode = rhsNode!.previous }

                guard let usedNode = rhsNode else { return }
                guard usedNode !== head else { return }
                
                // Find space big enough to hold the node
                guard let emptyNode = nextEmpty(fitting: usedNode) else {
                    rhsNode = usedNode.previous
                    continue
                }
                
                // Replace used node for empty space
                if let previousEmpty = usedNode.previous, previousEmpty.type.isEmpty {
                    previousEmpty.length += usedNode.length
                } else {
                    let newEmptyNode = Node.empty(length: usedNode.length)
                    insert(node: newEmptyNode, before: usedNode)
                }
                
                // Remove the used node from the list
                remove(node: usedNode)
                rhsNode = usedNode.previous
                
                // Combine empty space around the removed area
                if let previousEmpty = usedNode.previous, previousEmpty.type.isEmpty {
                    if let nextEmpty = usedNode.next, nextEmpty.type.isEmpty {
                        previousEmpty.length += nextEmpty.length
                        remove(node: nextEmpty)
                    }
                }

                // Inject the used node before the empty space
                insert(node: usedNode, before: emptyNode)
                
                // Decrement the empty space and remove it if needed
                emptyNode.length -= usedNode.length
                
                if emptyNode.length == 0 {
                    remove(node: emptyNode)
                }
            }
        }
        
        private func insert(node: Node, before other: Node) {
            node.previous = other.previous
            node.next = other
            
            other.previous?.next = node
            other.previous = node
        }
        
        private func insert(node: Node, after other: Node) {
            node.next = other.next
            node.previous = other
            
            other.next?.previous = node
            other.next = node
        }
        
        private func remove(node: Node) {
            node.previous?.next = node.next
            node.next?.previous = node.previous
        }

        private func nextEmpty(fitting other: Node) -> Node? {
           var lhsNode = head
            
            while let node = lhsNode {
                guard node !== other else { return nil }
                
                if node.type.isEmpty && node.length >= other.length {
                    return node
                }
                
                lhsNode = node.next
            }
            
            return nil
        }
        
        func printFilesystem() {
            var currentNode = head
            
            while let node = currentNode {
                print("[\(node.description)]", terminator: "")
                currentNode = node.next
            }
            
            print()
        }
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        let filesystem = Filesystem(data: data)
        filesystem.compact()
        
        return filesystem.checksum
    }
    
    public func part2() async throws -> Any {
        let filesystem = Filesystem(data: data)
        filesystem.compactBetter()
        
        return filesystem.checksum
    }
}
