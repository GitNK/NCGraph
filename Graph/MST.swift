//
//  MST.swift
//  NCGraph
//
//  Created by Nikita Gromadskyi on 9/29/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import Foundation



/// MST algorithms
public enum MSTAlgorithm {
    /// Primm`s algorithm for undirected graph
    case primms
    /// Kruskal`s algorithm for undirected graph
    case kruskals
}
extension NCGraph {
    /// Computes minimum spaning tree
    /// - parameter using: algorithm to be used
    /// - complexity: `O(m*logn)`, `m` - number of edges,
    ///               `n` - number of nodes
    /// - returns: array of edges representing mst
    ///            or nil if `self` does not have mst
    public func mst(using: MSTAlgorithm) -> [EdgeType]? {
    
        if self.isDirected || edgeCount == 0 {return nil}
        
        switch using {
        case .primms:
            return primmsAlgorithm()
        case .kruskals:
            return kruskalsAlgorithm()
        }
    }
    
    //# MARK: - Private section
    
    private func primmsAlgorithm() -> [EdgeType]? {
        
        /// Array of edges representing mst
        var mst = [EdgeType]()
        /// Set of explored and added to mst nodes
        var exploredNodes = Set<NodeType.Name>()
        /// Map from `Name` to mstNode
        var nameMSTMap = [Name: MSTNode<NodeType, EdgeType>]()
        /// Init input nodes
        let inputNodes = nodes().map({(node) -> MSTNode<NodeType, EdgeType> in

            let mstNode = MSTNode<NodeType,EdgeType>(name: node.name)
            nameMSTMap[node.name] = mstNode
            return mstNode
        })
        /// Set arbitrary first node score to 0
        if let first = inputNodes.first {
            first.score = 0
            exploredNodes.insert(first.name)
        } else {return nil}
        
        
        /// Add all vertices from input to heap
        var nodeHeap = NCBinaryHeap(input: inputNodes)
        /// Second heap for score recompute
        var secondRoundHeap = NCBinaryHeap<EdgeType>()
        
        while nodeHeap.count != 0 {
            
            /// Pop node with smallest score
            guard let firstWinner = nodeHeap.pop() else {fatalError()}
            /// Фdd winner edge with smallest weight to mst
            if let winnerEdge = firstWinner.winnerEdge {
                mst.append(winnerEdge)
                exploredNodes.insert(firstWinner.name)
            }
            /// Adjacent edges for winner node with smallest score
            /// Returns nil on disconnected graph
            guard let adjacentEdges = self.adjacentEdgesFor(nodeNamed: firstWinner.name) else {return nil}
            /// Recompute score for adjacent nodes
            /// with edges that cross the mst frontier
            for edge in adjacentEdges {
                
                /// Get 2nd node of the edge that crosses the frontier
                let crossNode = edge.tail.name != firstWinner.name ? edge.tail.name : edge.head.name
                guard let crossMSTNode = nameMSTMap[crossNode] else{fatalError()}
                if exploredNodes.contains(crossNode) {
                    continue
                }
                /// Remove 2nd node from heap
                guard let index = nodeHeap.indexOf(crossMSTNode) else {fatalError()}
                assert((nodeHeap.remove(at: index) != nil))
                /// Autorelease second round heap allocations
                autoreleasepool{
                    /// Recompute score
                    secondRoundHeap.removeAll()
                    guard let adjacentEdges2nd = self.adjacentEdgesFor(nodeNamed: crossNode) else {fatalError()}
                    for edge in adjacentEdges2nd {
                        if exploredNodes.contains(edge.tail.name) || exploredNodes.contains(edge.head.name) {
                            secondRoundHeap.push(edge)
                        }
                    }
                    guard let secondWinner = secondRoundHeap.pop() else {fatalError()}
                    crossMSTNode.score = secondWinner.weight
                    crossMSTNode.winnerEdge = secondWinner
                    /// Add node with recomputed score back to heap
                    nodeHeap.push(crossMSTNode)
                }
            }
        }
        return mst
    }
    
    private func kruskalsAlgorithm() -> [EdgeType]? {
        /// Array of edges representing mst
        var mst = [EdgeType]()
        /// Create Union Find DS with nodes from `self`
        var unionFind = NCUnionFind(inputNodes: nodes())
        /// Binary heap with edges from `self`
        var binaryHeap = NCBinaryHeap(input: self.edges())
        while binaryHeap.count > 0 {
            /// Get edge with smallest weight from binary heap
            guard let edge = binaryHeap.pop(),
                let first = unionFind.find(node: edge.head),
                let second = unionFind.find(node: edge.tail)
                else {return nil}
            /// If first and second node belong to different clusters - make union
            if first != second {
                guard unionFind.union(first: first,
                                      second: second) else {fatalError()}
                mst.append(edge)
            }
        }
        return mst
    }
}
/// Private node class for primms mst algorithm
private final class MSTNode<NodeType: NCNodeProtocol, EdgeType: NCEdgeProtocol>:Comparable {
    
    var name: NodeType.Name
    var score: Int
    var winnerEdge: EdgeType?
    
    init(name: NodeType.Name, score: Int = Int.max) {
        self.name = name
        self.score = score
    }
    
    static func <(lhs: MSTNode, rhs: MSTNode) -> Bool {
        return lhs.score < rhs.score
    }
    
    static func ==(lhs: MSTNode, rhs: MSTNode) -> Bool {
        return lhs.name == rhs.name
    }
}
