//
//  NCUnionFind.swift
//  NCGraph
//
//  Created by Nikita Gromadskyi on 10/1/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import Foundation

/**
 Union Find data structure.
 

 */
public struct NCUnionFind<Node:Hashable> {
    
    /// array of nodes
    internal var clusters:[ClusterNode<Node>]
    /// number of clusters
    internal var kCount:Int
    /// nodeMap used to map client nodes to indices
    /// of internal cluster array
    internal var nodeMap:[Node: Int]
    
    public init(inputNodes:[Node]){
        kCount = inputNodes.count
        clusters = Array<ClusterNode<Node>>()
        nodeMap = Dictionary<Node, Int>()
        loadNodes(nodes: inputNodes)
        
    }
    
    /// finds leader (cluster) of the input node
    /// - parameter node: input node that was previously loaded
    ///   into structure
    /// - returns: leader node or nil if no matching node is found
    public mutating func find(node: Node) -> Node? {
        if let clusterNode = nodeMap[node], let leader = find(clusterID: clusterNode) {
            return clusters[leader.id].node
        }
        return nil
    }

    /// makes a union of input nodes
    /// - parameters:
    ///     - first: first node
    ///     - second: second node
    /// - returns: true if nodes has been united into common cluster,
    /// false on illegal or same cluster nodes
    public mutating func union(first: Node, second: Node) -> Bool {
        if let firstID = nodeMap[first], let secondID = nodeMap[second] {
            return union(firstClusterID: firstID, secondClusterID: secondID)
        }
        return false
    }
    
    /// - returns: number of clusters
    public func clusterCount() -> Int {
        return kCount
    }
    
    //# MARK: - Private section
    
    /// loads input nodes to clusters array and maps them to 
    /// its indices
    private mutating func loadNodes(nodes: [Node]) {
        nodes.enumerated().forEach { (idx, node) in
            let clusterNode = ClusterNode(node: node, id: idx,
                                          rank: 0,
                                          leader: idx)
            nodeMap[node] = idx
            clusters.append(clusterNode)
        }
    }
    
    /// find leader (cluster) of the given node
    internal mutating func find(clusterID:Int) -> ClusterNode<Node>? {
        
        // base case check
        if clusterID >= clusters.count {
            return nil
        }
        /// visited nodes during this find operation
        var visited = [Int]()
        let leader = findHelper(findID: clusterID, visited: &visited)
        for i in visited {
            clusters[i].leader = leader
        }
        return clusters[leader]
    }
    
    /// recursive helper for find method
    internal func findHelper(findID:Int, visited:inout [Int]) -> Int {
        let locLeaderID = clusters[findID].leader
        if  locLeaderID != findID {
            visited.append(findID)
            return findHelper(findID: locLeaderID, visited: &visited)
        }
        return locLeaderID
    }
    
    /// union two nodes (clusters)
    private mutating func union(firstClusterID: Int, secondClusterID: Int) -> Bool {
        
        guard let firstRoot = find(clusterID: firstClusterID) else {
            return false
        }
        guard let secondRoot = find(clusterID: secondClusterID) else {
            return false
        }
        if firstRoot.leader == secondRoot.leader {
            return false
        }
        if firstRoot.rank == secondRoot.rank {
            firstRoot.rank += 1
            secondRoot.leader = firstRoot.leader
        } else if firstRoot.rank > secondRoot.rank {
            secondRoot.leader = firstRoot.leader
        } else {
            firstRoot.leader = secondRoot.leader
        }
        kCount -= 1
        return true
    }
    
    /// simple description
    internal func description() -> String {
        var desc = ""
        for cluster in clusters {
            desc.append("\(cluster.node)->\(clusters[cluster.leader]) ")
        }
        return desc
    }
}

final internal class ClusterNode<Node>:Comparable {
    
    var node: Node
    var id:Int
    var rank:Int
    var leader:Int
    
    init(node: Node, id:Int, rank:Int, leader:Int){
        self.node = node
        self.id = id
        self.rank = rank
        self.leader = leader
    }
    
    static func ==(firstNode: ClusterNode, secondNode: ClusterNode) -> Bool {
        return firstNode.id == secondNode.id &&
            firstNode.rank == secondNode.rank &&
            firstNode.leader == secondNode.leader
    }
    
    static func <(firstNode: ClusterNode, secondNode: ClusterNode) -> Bool {
        return firstNode.rank < secondNode.rank
    }
}



