//
//  NCEdge.swift
//  NCGraph
//
//  Created by Nikita Gromadskyi on 10/16/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import Foundation


//# MARK: TODO MAYBE: Remove defensive copying?
/**
 Class for Edge object.
 Needs to be inherited from by custom clasees
 in order to be used in Graph ADT.
 conform to Comparable protocol
 */
public final class NCEdge: NCEdgeProtocol, Comparable {
    
    private var _tail: NCNode
    private var _head: NCNode
    public var weight: Int

    public var tail: NCNode {return _tail}
    
    public var head: NCNode {return _head}
    
    public required init(tail: NCNode, head: NCNode, weight: Int = 0) {
        self._tail = tail
        self._head = head
        self.weight = weight
    }
    
    public convenience init(tailName: NCNode.Name, headName: NCNode.Name, weight: Int = 0) {
        self.init(tail: NCNode(name: tailName), head: NCNode(name: headName), weight: weight)
    }
    
    public required convenience init(edge: NCEdge) {
        self.init(tail: edge.tail, head: edge.head, weight: edge.weight)
    }
    
    static public func ==(lhs: NCEdge, rhs: NCEdge) -> Bool {
        return lhs.tail == rhs.tail && lhs.head == rhs.head &&
            lhs.weight == rhs.weight
    }
    
    static public func <(lhs: NCEdge, rhs: NCEdge) -> Bool {
        return lhs.weight < rhs.weight
    }
}





/*
public struct NCEdge: NCEdgeProtocol, Comparable {
    
    public var tailNode: NCNode
    public var headNode: NCNode
    public var weight: Int
    
    
    public init(tailNode: NCNode, headNode: NCNode, weight: Int = 0) {
        self.tailNode = tailNode
        self.headNode = headNode
        self.weight = weight
    }
    
//    public var hashValue: Int {
//        return "\(tailNode.name) - \(headNode.name) : \(weight)".hashValue
//    }
    
    public init(tailName: NCNode.Name, headName: NCNode.Name, weight: Int = 0) {
        self.init(tailNode: NCNode(name: tailName), headNode: NCNode(name: headName), weight: weight)
    }
    
    public init(edge: NCEdge) {
        self.init(tailNode: edge.tailNode, headNode: edge.headNode, weight: edge.weight)
    }
    
    public static func ==(lhs: NCEdge, rhs: NCEdge) -> Bool {
        return lhs.tailNode == rhs.tailNode && lhs.headNode == rhs.headNode &&
        lhs.weight == rhs.weight
    }
    
    public static func <(lhs: NCEdge, rhs: NCEdge) -> Bool {
        return lhs.weight < rhs.weight
    }
    
}
*/
