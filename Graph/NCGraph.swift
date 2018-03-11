//
//  NCGraph.swift
//  NCGraph
//
//  Created by Nikita Gromadskyi on 7/5/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import Foundation

/// Protocol for custom `Node` types can be usable in `NCGraph`
public protocol NCNodeProtocol: Comparable {
    
    associatedtype Name:Hashable
    
    var name: Name {get}
    
    init(name: Name)
    init(node: Self)
    
    static func ==(lhs: Self, rhs: Self) -> Bool
    static func <(lhs: Self, rhs: Self) -> Bool
}

/// Protocol for custom `Edge` types that can be used in `NCGraph`
public protocol NCEdgeProtocol {
    
    associatedtype NodeType: NCNodeProtocol
    
    var tail: NodeType {get}
    var head: NodeType {get}
    var weight: Int {get set}
    
    init(tail: NodeType, head: NodeType, weight: Int)
    init(edge: Self)
    
    static func ==(lhs: Self, rhs: Self) -> Bool
    static func <(lhs: Self, rhs: Self) -> Bool
}

/**
 
 **Graph - Abstract Data Type**.
 
 `Graph` object works with any `Node` and `Edge` types 
 that conform to `NCNodeProtocol` and `NCEdgeProtocol`
 
 Dublicate vertices would be ignored and not added to graph.
 `isDirected` variable used to change graph type (directed or undirected).
 `allowParallelEdges` is set during initialization and cannot be changed afterwards
 
 
 */
public struct NCGraph<NodeType, EdgeType: NCEdgeProtocol>
    where NodeType: Hashable,
    EdgeType: Comparable,
    EdgeType.NodeType == NodeType
{
    /// Type of the `node`'s name
    public typealias Name = NodeType.Name
    /// array of edges in `self`
    private var _edges: [EdgeType]
    /// dictionary of container nodes
    private var _nodeMap: [Name: ContainerNode<NodeType, EdgeType>]
    /// A boolean value indicating directed/undirected graph
    public var isDirected: Bool
    /// Instance variable for parallel edges indicator
    private var _allowParallelEdges: Bool
    /// A boolean value indicating parallel edges
    public var allowParallelEdges: Bool {return _allowParallelEdges}
    /// Instance variable for graph weight
    private var _weight: Int
    /// Graph weight
    public var weight: Int {return _weight}
    /// Returns number of nodes in graph
    public var nodeCount: Int {return _nodeMap.keys.count}
    /// Returns number of edges in graph
    public var edgeCount: Int {return _edges.count}
    /// A boolean value indicating if graph is empty
    public var isEmpty: Bool {return nodeCount == 0}
    
    /// Initializes self as a copy of input `graph`
    public init(graph: NCGraph) {
        self.init(isDirected: graph.isDirected,
                  allowParallelEdges: graph._allowParallelEdges)
        self.isDirected = graph.isDirected
        self._allowParallelEdges = graph._allowParallelEdges
        for edge in graph.edges() {
            assert(self.addEdge(EdgeType(edge: edge)))
        }
    }
    
    public init(isDirected: Bool, allowParallelEdges: Bool) {
        _edges = [EdgeType]()
        _nodeMap = Dictionary<Name, ContainerNode<NodeType, EdgeType>>()
        self.isDirected = isDirected
        self._allowParallelEdges = allowParallelEdges
        self._weight = 0
    }

    /// - complexity: O(m)
    // A boolean value indicating if `self` is a complete graph
    public var isComplete: Bool {
        let n = nodeCount; let m = edgeCount;
        /// quick checks
        if isDirected && m < n*(n-1) {return false}
        else if !isDirected && m < n*(n-1)/2 {return false}
        /// dictionary for mapping nodes to indices of an array
        var indexdMap = Dictionary<NodeType, Int>()
        /// set nodes as keys and indices as values
        for (index, val) in nodes().enumerated() {
            indexdMap.updateValue(index, forKey: val)
        }
        /// array for lookups
        var lookup = Array<Bool>(repeating: false, count: n*n)
        /// set true for all parallel edges in lookup
        for i in 0..<n {lookup[mapFunc(i: i, j: i)] = true}
        for edge in edges() {
            /// skip self loops if any
            if isSelfLoop(edge: edge) {continue}
            /// get mapped indexes of nodes
            guard let tailIndex = indexdMap[edge.tail], let headIndex = indexdMap[edge.head] else {
                fatalError()
            }
            /// set value to true for mapped edge
            lookup[mapFunc(i: tailIndex, j: headIndex)] = true
            /// add extra value for back edge for undirected graph
            if !isDirected {lookup[mapFunc(i: headIndex, j: tailIndex)] = true}
        }
        if lookup.contains(false) {return false}
        return true
    }
    
    /// removes all edges and nodes from the graph
    public mutating func removeAll() {
        _edges = [EdgeType]()
        _nodeMap = Dictionary<Name,ContainerNode<NodeType,EdgeType>>()
        self._weight = 0
    }
    
    //# MARK: - Operations on *nodes*
    
    /// Returns array of existing nodes in `self`
    public func nodes() -> [NodeType] {
        return _nodeMap.values.flatMap{$0.graphNode}
    }
    
    public mutating func addNode(named name: Name) -> Bool {
        return addNode(NodeType(name: name))
    }
    
    /// Adds node to `self`
    /// - parameter node: should be of `NodeType`
    /// - returns: `true` if node was added,
    ///   `false` if node with same name already present
    public mutating func addNode(_ node: NodeType) -> Bool {
        if _nodeMap[node.name] != nil {
            return false
        }
        self._nodeMap[node.name] = ContainerNode(graphNode: node)
        return true
    }
    
    /// Adds `nodes` from input `array`
    /// - note: dublicate nodes will be ignored
    public mutating func addNodesFrom(array nodes:[NodeType]) {
        for node in nodes {
            _ = addNode(node)
        }
    }
    
    /// Returns `true` if `self` contains `node`
    public func containsNode(_ node: NodeType) -> Bool {
        return containsNode(named: node.name)
    }
    /// Returns true if `self` contains `node` with input `name`
    public func containsNode(named name: Name) -> Bool {
        if _nodeMap[name] != nil {return true}
        return false
    }
    
    /// Returns `node` with input `name` or nil if not found
    public func getNode(name: Name) -> NodeType? {
        if let container = _nodeMap[name] {
            return container.graphNode
        }
        return nil
    }
    
    /// Removes input `node` from `self` 
    /// - returns: `true` on seccessful removal,
    /// `false` if `node` not found in `self`
    public mutating func removeNode(_ node: NodeType) -> Bool {
        return removeNode(named: node.name)
    }
    
    /// Removes `node` with input `name` from 'self'
    /// - returns: `true` on seccessful removal,
    /// `false` if `node` not found in `self`
    public mutating func removeNode(named name: Name) -> Bool {
        /// remove all edges associated with node
        if let adjEdges = adjacentEdgesFor(nodeNamed: name) {
            for edge in adjEdges {
                assert(removeEdge(edge) != nil)
            }
            _nodeMap[name] = nil
            return true
        } else {return false}
    }
    
    // MARK: - Operations on *edges*
    
    /// Returns array of existing edges in `self`
    public func edges() -> [EdgeType] {
        return _edges
    }
    
    /// Initializes and adds an `edge` with provided `tail`, `head` and `weight`.
    /// - returns: `true` if edge was added, `false` if edge is present and parallel edges are not allowed
    public mutating func addEdgeWith(tail: NodeType, head: NodeType, weight: Int) -> Bool {
        return addEdge(EdgeType(tail: tail, head: head, weight: weight))
    }
    
    /// Initializes and adds an edge with provided `tailName`, `headName` and `weight`.
    /// - returns: `true` if edge was added, `false` if edge is present and parallel edges are not allowed
    public mutating func addEdgeWith(tailName: Name, headName: Name, weight: Int) -> Bool {
        return addEdgeWith(tail: NodeType(name: tailName), head: NodeType(name: headName), weight: weight)
    }
    
    /// Adds `edge` to `self`
    /// - returns: `true` if edge was added, `false` if edge is present and parallel edges are not allowed
    public mutating func addEdge(_ edge: EdgeType) -> Bool {
        /// Check if parallel edge is allowed and if already present
        if !allowParallelEdges && containsEdge(edge){
            return false
        }
        
        let tailNode = edge.tail
        let headNode = edge.head
        
        if let firstContainerNode = _nodeMap[tailNode.name] {
            firstContainerNode.outDegreeEdges.append(edge)
        } else {
            _nodeMap[tailNode.name] = ContainerNode(graphNode: tailNode,
                                                    inDegreeEdges: [EdgeType](),
                                                    outDegreeEdges: [edge])
        }
        if let secondContainerNode = _nodeMap[headNode.name] {
            secondContainerNode.inDegreeEdges.append(edge)
        } else {
            _nodeMap[headNode.name] = ContainerNode(graphNode: headNode,
                                                    inDegreeEdges: [edge],
                                                    outDegreeEdges: [EdgeType]())
            
        }
        _edges.append(edge)
        _weight += edge.weight
        return true
    }
    
    /// Adds `edges` from input `array`
    /// - note: Parallel edges would be added in case if `allowParallelEdges` was set to `true`
    public mutating func addEdgesFrom(array edges:[EdgeType]){
        for edge in edges {
            _ = addEdge(edge)
        }
    }
    
    /// Method for getting adjacentEdges for `node`
    /// - returns: `array` of adjacent edges in `self` for `node`,
    ///   `nil` if node is not present
    /// - parameter node: input `node` that present in `self`
    public func adjacentEdgesFor(node:NodeType) -> [EdgeType]? {
        return adjacentEdgesFor(nodeNamed: node.name)
    }
    
    /// Method for getting adjacentEdges for node's `name`
    /// - returns: `array` of adjacent edges in `self` for node `name`,
    ///   `nil` if node is not present
    /// - parameter node: input node `name` that present in `self`
    public func adjacentEdgesFor(nodeNamed name: Name) -> [EdgeType]? {
        if let container = _nodeMap[name] {
            return (container.inDegreeEdges + container.outDegreeEdges)
        } else {
            return nil
        }
    }
    /// Method for getting in-degree edges for `node`
    /// - returns: an `array` of in-degree edges in `self` for `node`, `nil`
    /// if node is not found.
    /// - note: If the graph is undirected adjacent edges would be returned instead
    public func inDegreeEdgesFor(node: NodeType) -> [EdgeType]? {
        return inDegreeEdgesFor(nodeNamed: node.name)
    }
    
    /// Method for getting in-degree edges for node's `name`
    /// - returns: an `array` of in-degree edges in `self` for `node`, `nil`
    /// if node is not found.
    /// - note: If the graph is undirected adjacent edges would be returned instead
    public func inDegreeEdgesFor(nodeNamed name: Name) -> [EdgeType]? {
        /// special case for undirected
        if !isDirected {return adjacentEdgesFor(nodeNamed: name)}
        if let container = _nodeMap[name] {
            /// copy on return
            return container.inDegreeEdges
        } else {
            return nil
        }
    }
    
    /// Method for getting out-degree edges for `node`
    /// - returns: an `array` of out-degree edges in `self` for `node`, `nil`
    /// if node is not found.
    /// - note: If the graph is undirected adjacent edges would be returned instead
    public func outDegreeEdgesFor(node: NodeType) -> [EdgeType]? {
        return outDegreeEdgesFor(nodeNamed: node.name)
    }
    
    /// Method for getting out-degree edges for node's `name`
    /// - returns: an `array` of out-degree edges in `self` for `node`, `nil`
    /// if node is not found.
    /// - note: If the graph is undirected adjacent edges would be returned instead
    public func outDegreeEdgesFor(nodeNamed name: Name) -> [EdgeType]? {
        /// special case for undirected
        if !isDirected {return adjacentEdgesFor(nodeNamed: name)}
        if let contNode = _nodeMap[name] {
            /// copy on return
            return contNode.outDegreeEdges
        } else {
            return nil
        }
    }
    
    /// Returns true if `edge` is present in `self`.
    public func containsEdge(_ edge: EdgeType) -> Bool {
        if containsNode(edge.head),
            let tailOutEdges = outDegreeEdgesFor(node: edge.tail){
            if isDirected {return tailOutEdges.contains(edge)}
            else {return tailOutEdges.contains(edge)
                || tailOutEdges.contains(reverseEdge(edge))}
        } else {return false}
    }
    /// Returns true if edge with `tail`, `head` and `weight` is present in `self`.
    public func containsEdgeWith(tail: NodeType, head: NodeType, weight: Int = 0) -> Bool {
        return containsEdgeWith(tailName: tail.name,
                                headName: head.name,
                                weight: weight)
    }
    /// Returns true if edge with `tailName`, `headName` and `weight` is present in `self`.
    public func containsEdgeWith(tailName: Name, headName: Name, weight: Int = 0) -> Bool {
        if getEdgeWith(tailName: tailName,
                       headName: headName,
                       weight: weight) != nil {return true}
        else {return false}
    }
    
    /// Returns `edge` from `self` itentical to input `edge`, nil if none found
    public func getEdge(_ edge: EdgeType) -> EdgeType? {
        return getEdgeWith(tailName: edge.tail.name, headName: edge.head.name, weight: edge.weight)
    }
    
    /// Returns `edge` from `self` that matches `tail`, `head` and `weight`, nil if none found
    public func getEdgeWith(tail: NodeType, head: NodeType, weight: Int = 0) -> EdgeType? {
        return getEdgeWith(tailName: tail.name, headName: head.name, weight: weight)
    }
    
    /// Returns `edge` from `self` that matches `tailName`, `headName` and `weight`, nil if none found
    public func getEdgeWith(tailName: Name, headName: Name, weight: Int = 0) -> EdgeType? {
        /// gets out degree edges for tailName
        /// for undirected outEdges are semantically adjacent
        guard  containsNode(named: headName),
            let outEdges = outDegreeEdgesFor(nodeNamed: tailName) else {
                return nil
        }
        for edge in outEdges {
            if edge.tail.name == tailName
                && edge.head.name == headName
                && edge.weight == weight {return edge}
            else if !isDirected && edge.tail.name == headName
                && edge.head.name == tailName
                && edge.weight == weight {return edge}
        }
        return nil
    }
    
    /// Returns array of all `edges` for `tail` and `head`,
    /// `nil` if none exist in `self`
    public func getEdgesFor(tail: NodeType, head: NodeType) -> [EdgeType]? {
        return getEdgesFor(tailName: tail.name, headName: tail.name)
    }
    
    /// Returns array of all `edges` for `tailName` and `headName`,
    /// `nil` if none exist in `self`
    public func getEdgesFor(tailName: Name, headName: Name) -> [EdgeType]? {
        var edges = [EdgeType]()
        if containsNode(named: headName),
            let outDegEdges = outDegreeEdgesFor(nodeNamed: tailName){
            edges = outDegEdges.filter{$0.tail.name == tailName
                && $0.head.name == headName}
            // special case for undirected
            if !isDirected {
                edges += outDegEdges.filter{$0.tail.name == headName
                    && $0.head.name == tailName}
            }
        }
        if edges.isEmpty {return nil}
        return edges
    }
    
    /// Removes input `edge` from `self`
    /// - returns: removed edge or nil if none found
    public mutating func removeEdge(_ edge: EdgeType) -> EdgeType? {
        return removeEdgeWith(tailName: edge.tail.name, headName: edge.head.name, weight: edge.weight)
    }
    
    /// Removes `edge` with `tail`, `head` and `weight` from `self`
    /// - returns: removed edge or nil if none found
    public mutating func removeEdgeWith(tail: NodeType, head: NodeType, weight: Int = 0) -> EdgeType? {
        return removeEdgeWith(tailName: tail.name, headName: head.name, weight: weight)
    }
    
    /// Removes `edge` with `tailName`, `headName` and `weight` from `self`.
    /// - returns: removed edge or nil if none found
    public mutating func removeEdgeWith(tailName: Name, headName: Name, weight: Int = 0) -> EdgeType? {
        guard let tailContainer = _nodeMap[tailName],
            let headContainer = _nodeMap[headName],
            let edge = getEdgeWith(tailName: tailName,
                                   headName: headName,
                                   weight: weight)
            else {return nil}
        
        tailContainer.outDegreeEdges = tailContainer.outDegreeEdges.filter({$0 != edge})
        headContainer.inDegreeEdges = headContainer.inDegreeEdges.filter({$0 != edge})
        
        
        _weight -= edge.weight
        guard let index = _edges.index(of: edge) else {return nil}
        _edges.remove(at: index)
        return edge
    }
    
    
    public mutating func removeEdgesWith(tailName: Name, headName: Name) -> [EdgeType]? {
        var removed = [EdgeType]()
        
        if let fEdges = getEdgesFor(tailName: tailName, headName: headName) {
            for edge in fEdges {
                assert(removeEdge(edge) != nil)
            }
            removed += fEdges
        }
        if removed.isEmpty {return nil}
        return removed
    }
    
    //# MARK: - Private helper functions
    
    /// Helper function to check if `edge` is a self loop
    private func isSelfLoop(edge: EdgeType) -> Bool {
        return edge.tail == edge.head
    }
    
    /// function to map an array (i,j) to bool array
    private func mapFunc(i:Int, j:Int) -> Int {
        return i*nodeCount+j
    }
    
    private func reverseEdge(_ edge: EdgeType) -> EdgeType {
        return EdgeType(tail: edge.head,
                        head: edge.tail,
                        weight: edge.weight)
    }
}

/// Private container class for encapsulating `Node`s with their adjacent `Edge`s
private final class ContainerNode<NodeType: NCNodeProtocol, EdgeType: NCEdgeProtocol> {
    var graphNode: NodeType
    var inDegreeEdges: [EdgeType]
    var outDegreeEdges: [EdgeType]
    
    init(graphNode: NodeType,
         inDegreeEdges: [EdgeType],
         outDegreeEdges:[EdgeType]) {
        self.graphNode = graphNode
        self.inDegreeEdges = inDegreeEdges
        self.outDegreeEdges = outDegreeEdges
    }
    convenience init(graphNode: NodeType) {
        self.init(graphNode:graphNode,
                  inDegreeEdges: [EdgeType](),
                  outDegreeEdges: [EdgeType]())
    }
}
