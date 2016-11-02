//
//  Clustering.swift
//  NCGraph
//
//  Created by Nikita Gromadskyi on 10/21/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import Foundation


extension NCGraph {
    /// Method for computing max-spacing of k-clustering
    /// - note: `self` should be ia a form of complete graph with edge costs.
    /// - returns: max-spacing of k-clustering for self.
    func kClusteringMaxSpacing(k: Int) -> Int {
        /// Initialize union find ds with `nodes`
        var uFind = NCUnionFind(inputNodes: self.nodes())
        
        /// BinaryHeap for finding min edge
        var edgeHeap = NCBinaryHeap(input: self.edges())
        /// Maximum distance between clusters
        var maxDist = 0
        
        while edgeHeap.count != 0 {
            
            guard let currentEdge = edgeHeap.pop(),
                let firstNode = uFind.find(node: currentEdge.tail),
                let secondNode = uFind.find(node: currentEdge.head)
                else {return 0}
            
            if uFind.clusterCount() != k &&
                firstNode != secondNode {
                assert(uFind.union(first: firstNode, second: secondNode))
            } else if uFind.clusterCount() == k &&
                firstNode != secondNode {
                maxDist = currentEdge.weight
                return maxDist
            }
        }
        return 0
    }
}
