//
//  NCNode.swift
//  NCGraph
//
//  Created by Nikita Gromadskyi on 10/16/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import Foundation


//#MARK: TODO rename `Vertex` to `Node`

/**
 Class for vertex object.
 Open class used in Graph ADT.
 `Vertex` object represents Node/Vertex in
 directed or undirected graph.
 */
public final class NCNode: NCNodeProtocol, Hashable {
    
    public typealias Name = String
    
    public var name: Name
    
    public required init(name: Name) {
        self.name = name
    }
    
    public required convenience init(node: NCNode) {
        self.init(name: node.name)
    }
    
    
    public var hashValue: Int {
        return name.hashValue
    }
    
    public static func ==(lhs: NCNode, rhs: NCNode) -> Bool {
        return lhs.name == rhs.name
    }
    
    public static func <(lhs: NCNode, rhs: NCNode) -> Bool {
        return lhs.name < rhs.name
    }
    
}











/*
public struct NCNode:NCNodeProtocol, Hashable {

    public typealias Name = String
    
    public var name: Name
    //#MARK: TODO move score out from here
    public var score: Int
    
    public init(name: Name) {
        self.init(name: name, score: Int.max)
    }
    
    public init(node: NCNode) {
        self.init(name: node.name, score: node.score)
    }
    
    init(name: Name, score: Int = Int.max) {
        self.name = name
        self.score = score
    }
    
    public var hashValue: Int {
        return name.hashValue
    }
    
    public static func ==(lhs: NCNode, rhs: NCNode) -> Bool {
        return lhs.name == rhs.name
    }
    
    static public func <(lhs: NCNode, rhs: NCNode) -> Bool {
        return lhs.score < rhs.score
    }
    
    
}
*/
