//
//  DFS.swift
//  NCGraph
//
//  Created by Nikita Gromadskyi on 10/21/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import Foundation


extension NCGraph {
    
    /// A Boolean value indicating if `self` is directed acyclic graph
    public var isDAG :Bool {
        if edgeCount < 1 || !isDirected {
            return false
        }
        /// Set of deleted sink nodes
        var deleted = Set<Name>()
        /// Set of explored nodes
        var explored = Set<Name>()
        var hasCycle = false
        for node in nodes() {
            if !explored.contains(node.name){
                dfsCycleFinder(sourceNode: node,
                                  explored: &explored,
                                  deleted: &deleted,
                                  hasCycle: &hasCycle)
            }
            if hasCycle {return false} /// Early exit
        }
        
        return !hasCycle
    }
    /// Checks if `self` is directed strongly connected graph
    public var isStronglyConnected: Bool {
        return scc()?.count == 1
    }
    
    /// returns topologicaly sorted nodes for directed acyclic graph, nil if topological in not possible
    public func topSort() -> [NodeType]? {
        if !isDirected || !isDAG {return nil}
        
        var sortedNodes = [NodeType]()
        sortedNodes.reserveCapacity(nodeCount)
        
        var explored = Set<Name>()
        for node in nodes() {
            if !explored.contains(node.name) {
                dfs(sourceNode: node,
                    explored: &explored,
                    sortedNodes: &sortedNodes)
            }
        }
        return sortedNodes.reversed()
    }
    
    /// Method for finding strongly connected components
    /// of directed graph.
    /// - returns: 2d array representing strongly connected components,
    /// nil if none exist for `self`
    public func scc() -> [[NodeType]]? {
        if !isDirected || isEmpty {return nil}
        var _scc = [[NodeType]]()
        /// explored nodes
        var explored = Set<Name>()
        var newOrder = [NodeType]()
        /// first loop
        for node in nodes() {
            if !explored.contains(node.name) {
                dfsRev(sourceNode: node,
                              explored: &explored,
                              sortedNodes: &newOrder)
            }
        }
        /// reset explored nodes
        explored = Set<Name>()
        /// i-th strong component
        var strongComponent: [NodeType]
        /// second loop
        for node in newOrder.reversed() {
            if !explored.contains(node.name) {
                strongComponent = [NodeType]()
                dfs(sourceNode: node,
                           explored: &explored,
                           sortedNodes: &strongComponent)
                _scc.append(strongComponent)
            }
        }
        return _scc
    }
    //# MARK: - Private section
    private func dfs(sourceNode: NodeType,
                     explored: inout Set<Name>,
                     sortedNodes: inout [NodeType]) {
        /// stack of nodes
        var nodesToProcess = [sourceNode]
        while nodesToProcess.count > 0 {
            var inserted = false
            guard let current = nodesToProcess.last else {fatalError()}
            explored.insert(current.name)
            guard let outEdges = self.outDegreeEdgesFor(node: current) else {fatalError()}
            for edge in outEdges {
                if !explored.contains(edge.head.name) {
                    explored.insert(edge.head.name)
                    nodesToProcess.append(edge.head)
                    inserted = true
                    break
                }
            }
            if !inserted {
                nodesToProcess.removeLast()
                sortedNodes.append(current)
            }
        }
    }
    /// DFS with reversed direction edges
    private func dfsRev(sourceNode: NodeType,
                        explored: inout Set<Name>,
                        sortedNodes: inout [NodeType]) {
        /// nodes stack
        var nodesToProcess = [sourceNode]
        while nodesToProcess.count > 0 {
            var inserted = false
            guard let current = nodesToProcess.last else {fatalError()}
            explored.insert(current.name)
            guard let inEdges = self.inDegreeEdgesFor(node: current) else {fatalError()}
            for edge in inEdges {
                if !explored.contains(edge.tail.name) {
                    explored.insert(edge.tail.name)
                    nodesToProcess.append(edge.tail)
                    inserted = true
                    break
                }
            }
            if !inserted {
                nodesToProcess.removeLast()
                sortedNodes.append(current)
            }
        }
    }
    /// DFS Hepler for finding cycles in `self`
    private func dfsCycleFinder(sourceNode: NodeType,
                                   explored: inout Set<Name>,
                                   deleted: inout Set<Name>,
                                   hasCycle: inout Bool) {
        /// nodes stack
        var nodesToProcess = [sourceNode]
        while nodesToProcess.count > 0 {
            var inserted = false
            guard let current = nodesToProcess.last else {fatalError()}
            explored.insert(current.name)
            guard let outEdges = self.outDegreeEdgesFor(node: current) else {fatalError()}
            for edge in outEdges {
                if !explored.contains(edge.head.name) {
                    explored.insert(edge.head.name)
                    nodesToProcess.append(edge.head)
                    inserted = true
                    break
                } else {
                    /// check if head node has been marked as deleted
                    if !deleted.contains(edge.head.name) {
                        hasCycle = true
                    }
                }
            }
            if !inserted {
                nodesToProcess.removeLast()
                deleted.insert(current.name)
            }
        }
    }
    
}
