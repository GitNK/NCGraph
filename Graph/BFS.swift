//
//  BFS.swift
//  NCGraph
//
//  Created by Nikita Gromadskyi on 10/20/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import Foundation

extension NCGraph {
    
    /// Returns distance `from` source node `to` target,
    /// represented in number of hops
    public func numOfHops(from: NodeType, to: NodeType) -> Int? {
        
        if !self.containsNode(from) || !self.containsNode(to) {
            return nil
        }
        /// Explored nodes dist map
        var distMap = [Name: Int]()
        distMap[from.name] = 0
        
        bfs(source: from, distances: &distMap)
        return distMap[to.name]
    }
    /// Calculates connected components of undirected graph
    /// - returns: 2d array of connected components, nil if none
    public func connectedComponents() -> [[Name]]? {
        if isDirected || isEmpty {return nil}
        /// 2d array of connected components
        var ccs = [[Name]]()
        /// Map for number of hops from source
        var distMap:[Name: Int]
        /// Explored nodes
        var totalExplored = Set<Name>()
        for node in self.nodes() {
            distMap = [Name: Int]()
            if !totalExplored.contains(node.name) {
                distMap[node.name] = 0
                bfs(source: node, distances: &distMap)
                let explored = distMap.keys
                totalExplored.formUnion(explored)
                ccs.append(explored.map({$0}))
            }
        }
        return ccs
    }
    /// A boolean value indicating if undirected graph is connected
    /// - returns: true if graph is connected.
    public var isConnected: Bool {
        return !isDirected && connectedComponents()?.count == 1
    }
    
    //# MARK: - Private section
    /// Main bfs method
    private func bfs(source: NodeType, distances: inout [Name: Int]) {
        
        /// array used as queue to push elements
        var queue = [source]
        /// main loop
        while queue.count != 0 {
            
            let popped = queue.removeFirst()
            /// search out-degree in order to be directed graph proof
            if let edges = self.outDegreeEdgesFor(node: popped) {
                for edge in edges {
                    let tailName = edge.tail.name
                    let headName = edge.head.name
                    if  distances[tailName] == nil{
                        if let prevDist = distances[headName] {
                            distances[tailName] = prevDist + 1
                        }
                        queue.append(edge.tail)
                        
                    } else if distances[headName] == nil {
                        if let prevDist = distances[tailName] {
                            distances[headName] = prevDist + 1
                        }
                        queue.append(edge.head)
                    }
                }
            }
        }
    }
}
