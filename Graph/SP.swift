//
//  SP.swift
//  NCGraph
//
//  Created by Nikita Gromadskyi on 10/22/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import Foundation
import GameKit

/// Algorithms for Single Source Shourtest Paths (SSSP)
public enum SPAlgorithm {
    /// Dijkstra shortest path algoritm for non negative edge lengths
    case dijkstra
    /// Bellman-Ford algorithm with Yen optimizations,
    /// works with negative edge lengths without negative cycles
    case bellmanFord
}

extension NCGraph {
    /// Calculates shortest paths from source node to any other node. If no path between nodes
    /// exist dictionary won't contain that target node (key==nil)
    /// - returns: single-source shourtest path or nil if graph is either has negative
    /// length edge (for dijkstra) or negative cycle (for bellmanFord). Returns nil on graphs 
    /// with no edges or if `self` does not containe source node
    /// - complexity: O(m*logn) for dijkstra, O(m*n) for bellmanFord
    public func spFrom(source:NodeType, algorithm: SPAlgorithm) -> Dictionary<Name,[EdgeType]>? {
        if !self.containsNode(source) {return nil}
        switch algorithm {
        case .dijkstra:
            /// check for negative edges
            guard let min = edges().min(), min.weight >= 0 else {return nil}
            return dijkstraSP(source: source)
        case .bellmanFord:
            /// check if no edges
            guard edgeCount != 0 else {return nil}
            return bellmanFordYenSPV2(source: source)
        }
    }
    /// Calculates shortest paths from all source nodes to any other node. If no path between selected
    /// nodes exist, dictionary won't contain that target node (key==nil).
    /// - returns: all-source shourtest paths or nil if graph has negative cycle.
    /// - complexity: O(m*n*logn)
    public func assp() -> Dictionary<Name, Dictionary<Name, [EdgeType]>>? {
        
        
        
        return johnsonsASSP()
    }
    
    //# MARK: - Private section
    private func dijkstraSP(source: NodeType) -> Dictionary<Name,[EdgeType]>? {
        
        /// dictionary of shortest path from source to any other node
        var spMap = Dictionary<Name,[EdgeType]>()
        /// Set of exlored node so far
        var exploredNodes = Set<NodeType.Name>()
        /// Dictionary for quick accessing spNodes via `Name`
        var spNodeMap = [Name: SPNode<NodeType, EdgeType>]()
        /// init input nodes
        let inputNodes = nodes().map({ (node) -> SPNode<NodeType, EdgeType> in
            var score: Int
            if node == source {
                /// set source node score to 0
                score = 0
            } else {
                score = Int.max
            }
            let spNode = SPNode<NodeType, EdgeType>(name: node.name, score: score)
            spNodeMap[node.name] = spNode
            return spNode
        })
        /// load nodes to binary heap
        var binaryHeap = NCBinaryHeap<SPNode<NodeType,EdgeType>>(input: inputNodes)
        /// path so far from source node
        while binaryHeap.count != 0 {
            /// get current node with lowest score
            guard let curNode = binaryHeap.pop() else {fatalError()}
            /// special case for sink node
            if curNode.score == Int.max {continue}
            /// add current node with its shortest path to spMap
            spMap[curNode.name] = curNode.shortestPath
            /// add it to explored
            exploredNodes.insert(curNode.name)
            
            /// get outDegreeEdges
            guard let outDegreeEdges = outDegreeEdgesFor(nodeNamed: curNode.name) else {fatalError()}
            /// update score for outDegreeEdges
            for edge in outDegreeEdges {
                /// head node
                let headName = edge.head.name
                /// check that current edge crosses the frontier
                if !exploredNodes.contains(headName) {
                    /// get spNode for head name from map
                    guard let spNode = spNodeMap[headName] else {fatalError()}
                    /// if there is a new leader edge for given node
                    if spNode.score > curNode.score + edge.weight {
                        /// get index of spNode in binary heap
                        guard let headIndex = binaryHeap.indexOf(spNode) else {fatalError()}
                        assert(binaryHeap.remove(at: headIndex) != nil)
                        /// update score and edge, re-add to heap
                        spNode.score = curNode.score + edge.weight
                        binaryHeap.push(spNode)
                        /// add current edge to nodes shortest path
                        if let currentPath = curNode.shortestPath {
                            spNode.shortestPath = currentPath + [edge]
                        } else {
                            spNode.shortestPath = [edge]
                        }
                    }
                }
            }
        }
        return spMap
    }
    
    private func bellmanFordYenSPV2(source: NodeType) -> Dictionary<Name,[EdgeType]>? {
        
        /// dictionary of shortest path from source to any other node
        var spMap = Dictionary<Name,[EdgeType]>()
        /// Dictionary for quick accessing spNodes via `Name`
        var spNodeMap = [Name: SPNode<NodeType, EdgeType>]()
        /// init input nodes. score <=> distance
        var inputNodes = nodes().map({ (node) -> SPNode<NodeType, EdgeType> in
            var score: Int
            if node == source {
                /// set source node score to 0
                score = 0
            } else {
                score = Int.max
            }
            let spNode = SPNode<NodeType, EdgeType>(name: node.name, score: score)
            spNodeMap[node.name] = spNode
            return spNode
        })
        /// shuffle nodes
        if #available(iOS 9.0, *) {
            inputNodes = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: inputNodes) as! [SPNode]
        } else {
            // Fallback on earlier versions
            inputNodes.sort{ _,_ in arc4random()%2 == 0}
        }
        /// set of nodes for which `score` (dist) has changed
        var changedSet = Set<Name>()
        /// set of nodes for which `score` (dist) has changed per iteration
        var changesPerIter = Set<Name>()
        
        var gPlus = NCGraph(isDirected: true, allowParallelEdges: true)
        var gMinus = NCGraph(isDirected: true, allowParallelEdges: true)
        /// parent graph for negative cycle detection
        var pGraph = NCGraph(isDirected: true, allowParallelEdges: false)
        pGraph.addNodesFrom(array: nodes())
        
        /// load edges that go from lower node to higher to gPlus
        /// load edges that go from higher to lower nodes to gMinus
        for edge in edges() {
            if edge.tail < edge.head {
                assert(gPlus.addEdge(edge))
            } else {
                assert(gMinus.addEdge(edge))
            }
        }
        
        /// add source node
        changedSet.insert(source.name)
        
        var iterNum = 0
        while !changedSet.isEmpty {
            
            /// reset changes per iteration
            changesPerIter.removeAll()
            
            /// iterate in forward order
            for tail in inputNodes {
                
                if changedSet.contains(tail.name) || changesPerIter.contains(tail.name) {
                    if let outEdges = gPlus.outDegreeEdgesFor(nodeNamed: tail.name) {
                        /// forward edges
                        for fEdge in outEdges {
                            
                            guard let spHead = spNodeMap[fEdge.head.name] else {fatalError()}
                            let newDist = tail.score + fEdge.weight
                            
                            if spHead.score > newDist {
                                iterNum += 1
                                spHead.score = newDist
                                changesPerIter.insert(spHead.name)
                                if let tailPath = tail.shortestPath {
                                    spHead.shortestPath = tailPath + [fEdge]
                                } else {
                                    spHead.shortestPath = [fEdge]
                                }
                                
                                if iterNum > edgeCount/3 {
                                    _ = pGraph.addEdgeWith(tail: fEdge.head,
                                                           head: fEdge.tail,
                                                           weight: fEdge.weight)
                                }
                            }
                        }
                    }
                }
            }
            /// iterate in reversed order
            for tail in inputNodes.reversed() {
                
                if changedSet.contains(tail.name) || changesPerIter.contains(tail.name) {
                    if let outEdges = gMinus.outDegreeEdgesFor(nodeNamed: tail.name) {
                        /// back edges
                        for bEdge in outEdges {
                            
                            guard let spHead = spNodeMap[bEdge.head.name] else {fatalError()}
                            let newDist = tail.score + bEdge.weight
                            
                            if spHead.score > newDist {
                                iterNum += 1
                                spHead.score = newDist
                                changesPerIter.insert(spHead.name)
                                if let tailPath = tail.shortestPath {
                                    spHead.shortestPath = tailPath + [bEdge]
                                } else {
                                    spHead.shortestPath = [bEdge]
                                }
                                
                                if iterNum > edgeCount/3 {
                                 _ = pGraph.addEdgeWith(tail: bEdge.head,
                                 head: bEdge.tail,
                                 weight: bEdge.weight)
                                 }
                            }
                        }
                    }
                }
            }
            /// negative cycle detection
            if iterNum > edgeCount/3 &&
                pGraph.edgeCount > 0 &&
                !pGraph.isDAG
            {return nil}
            /// assign current changes
            changedSet = changesPerIter
        }
        /// write nodes to spMap
        for spNode in inputNodes {
            spMap[spNode.name] = spNode.shortestPath
        }
        return spMap
    }
    
    private func johnsonsASSP() -> Dictionary<Name, Dictionary<Name, [EdgeType]>>? {
        
        var assp = Dictionary<Name, Dictionary<Name, [EdgeType]>>()
        
        // First step: bellman ford zero node calculation
        var nodeIds = [Name:Int]()
        /// original nodes
        let origNodes = nodes()
        /// map original nodes to numeric ids (index+1)
        /// ids starting from 1
        origNodes.enumerated().forEach { (index, node) in
            nodeIds[node.name] = index+1
        }
        /// create new graph with internal nodes from ids
        var jGraph = NCGraph<JSPNode<NodeType>,JSPEdge<NodeType, EdgeType>>(isDirected: self.isDirected,
                                                                            allowParallelEdges: self.allowParallelEdges)
        for edge in edges() {
            if let tailID = nodeIds[edge.tail.name], let headID = nodeIds[edge.head.name] {
                let tail = JSPNode<NodeType>(name: tailID, originName: edge.tail.name)
                let head = JSPNode<NodeType>(name: headID, originName: edge.head.name)
                let newEdge = JSPEdge<NodeType,EdgeType>(tail: tail, head: head, weight: edge.weight)
                newEdge.originEdge = edge
                assert(jGraph.addEdge(newEdge))
            } else {
                fatalError()
            }
            
        }
        
        /// add zero node for reweighting
        let zeroNode = JSPNode<NodeType>(name: 0)
        /// add edges from zero to all nodes
        for node in jGraph.nodes() {
            
            assert(jGraph.addEdgeWith(tail: zeroNode,
                                      head: node, weight: 0))
        }
        
        /// values for edge reweight
        guard let spReweightVals = jGraph.spFrom(source: zeroNode,
                                                       algorithm: .bellmanFord) else {return nil}
        
        // Second step: edges rewighting and dijkstra
        
        /// exclude edges with zero node
        let jEdges = jGraph.edges().filter{$0.tail.name != 0}
        /// reweighted edges
        var rEdges = [JSPEdge<NodeType,EdgeType>]()
        /// load edges and reweight them, except edges with zero node as tail (tail != 0)
        for edge in jEdges {
            if  let tailSP = spReweightVals[edge.tail.name],
                let headSP = spReweightVals[edge.head.name] {
                let tailPval = tailSP.reduce(0){$0 + $1.weight}
                let headPval = headSP.reduce(0){$0 + $1.weight}
                let pWeight = edge.weight + tailPval - headPval
                let newEdge = JSPEdge(edge: edge)
                newEdge.weight = pWeight
                rEdges.append(newEdge)
            }
        }
        jGraph.removeAll()
        /// load reweighted edges back to graph
        jGraph.addEdgesFrom(array: rEdges)
        
        /// calculate sp for all sources using dijkstra algorithm
        for source in jGraph.nodes() {
            
            var origSourceSp = Dictionary<Name,[EdgeType]>()
            if let curSourceSP = jGraph.spFrom(source: source, algorithm: .dijkstra) {
                
                /// replase edges in current spMap
                for (target,sPath) in curSourceSP {
                    let nodeIdx = target-1
                    origSourceSp[origNodes[nodeIdx].name] = sPath.map{$0.originEdge!}
                }
                assp[source.originName!] = origSourceSp
            }
        }
        return assp
    }
}


/// Private class used to encapsulate `node`, id, `node`\`s score and shortest `edge`
private final class SPNode<NodeType: NCNodeProtocol, EdgeType: NCEdgeProtocol>: Comparable {
    
    var name: NodeType.Name
    var score: Int
    var shortestPath: [EdgeType]?
    
    init(name: NodeType.Name, score: Int) {
        self.name = name
        self.score = score
    }
    
    convenience init(name: NodeType.Name) {
        self.init(name: name, score: 0)
    }
    
    static func <(lhs: SPNode, rhs: SPNode) -> Bool {
        return lhs.score < rhs.score
    }
    
    static func ==(lhs: SPNode, rhs: SPNode) -> Bool {
        return lhs.name == rhs.name
    }
    
}

/// Private classes for Johnson's algoritms
private final class JSPNode<NodeType: NCNodeProtocol> : NCNodeProtocol, Hashable {
    
    fileprivate typealias Name = Int
    var name: Name
    var originName: NodeType.Name?
    
    fileprivate var hashValue: Int {
        return name.hashValue
    }
    init(name: Name, originName: NodeType.Name?) {
        self.name = name
        self.originName = originName
    }
    convenience init(name: Name) {
        self.init(name: name, originName: nil)
    }
    init(node: JSPNode) {
        self.name = node.name
        self.originName = node.originName
    }
    
    
    
    static func <(lhs: JSPNode, rhs: JSPNode) -> Bool {
        return lhs.name < rhs.name
    }
    static func ==(lhs: JSPNode, rhs: JSPNode) -> Bool {
        return lhs.name == rhs.name
    }

}

private final class JSPEdge<NodeType: NCNodeProtocol, EdgeType: NCEdgeProtocol>: NCEdgeProtocol, Comparable, Hashable {
    var originEdge: EdgeType?
    var tail: JSPNode<NodeType>
    var head: JSPNode<NodeType>
    var weight: Int
    
    fileprivate var hashValue: Int {
        return "\(tail.name) - \(head.name) : \(weight)".hashValue
    }
    
    init(tail: JSPNode<NodeType>, head: JSPNode<NodeType>, weight: Int) {
        self.tail = tail
        self.head = head
        self.weight = weight
    }
    convenience init(edge: JSPEdge) {
        self.init(tail: edge.tail, head: edge.head, weight: edge.weight)
        originEdge = edge.originEdge
    }
    
    
    static func ==(lhs: JSPEdge<NodeType, EdgeType>, rhs: JSPEdge<NodeType, EdgeType>) -> Bool {
        return lhs.head == rhs.head &&
               lhs.tail == rhs.tail &&
               lhs.weight == rhs.weight
    }
    static func <(lhs: JSPEdge<NodeType, EdgeType>, rhs: JSPEdge<NodeType, EdgeType>) -> Bool {
        return lhs.weight < rhs.weight
    }
    
}

