//
//  NCNode.swift
//  NCGraph
//
//  Created by Nikita Gromadskyi on 10/16/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import Foundation


/**
 Class for node object.
 Open class used in Graph ADT.
 `Node` object represents a Node in
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
