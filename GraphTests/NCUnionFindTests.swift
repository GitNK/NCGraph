//
//  NCUnionFindTests.swift
//  NCGraphTests
//
//  Created by Nikita Gromadskyi on 10/1/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import XCTest
@testable import NCGraph

class NCUnionFindTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFind_ShouldFindPreviouslyAddedNodes() {
        
        let clusterNode1 = 1
        let clusterNode2 = 2
        
        var union = NCUnionFind(inputNodes:[clusterNode1, clusterNode2])
        
        XCTAssertEqual(union.find(node: clusterNode1)!, clusterNode1)
        XCTAssertEqual(union.find(node: clusterNode2)!, clusterNode2)
    }
    
    func testUnion_ShouldUniteNodesIntoOneCluster() {
        
        let clusterNode1 = 1
        let clusterNode2 = 2
        
        var union = NCUnionFind(inputNodes: [clusterNode1, clusterNode2])
        
        XCTAssertEqual(union.clusterCount(), 2)
        XCTAssertTrue(union.union(first: clusterNode1, second: clusterNode2))
        XCTAssertEqual(union.find(node: clusterNode2), clusterNode1)
        XCTAssertEqual(union.clusterCount(), 1)
    }
    
    func testUnion_ShouldNotUniteNodesFromSameCluster() {
        
        let clusterNode1 = 1
        let clusterNode2 = 2
        let clusterNode3 = 3
        
        var union = NCUnionFind(inputNodes: [clusterNode1, clusterNode2, clusterNode3])
        
        XCTAssertEqual(union.clusterCount(), 3)
        XCTAssertTrue(union.union(first: clusterNode1, second: clusterNode2))
        XCTAssertTrue(union.union(first: clusterNode3, second: clusterNode2))
        XCTAssertFalse(union.union(first: clusterNode3, second: clusterNode1))
    }
    
    func testSut_ShouldChangeLeader() {
        
        let clusterNode1 = 1
        let clusterNode2 = 2
        let clusterNode3 = 3
        
        var union = NCUnionFind(inputNodes: [clusterNode1, clusterNode2, clusterNode3])
        
        XCTAssertTrue(union.union(first: clusterNode3, second: clusterNode2))
        XCTAssertEqual(union.clusterCount(), 2)
        XCTAssertEqual(union.find(node: clusterNode3), clusterNode3)
        XCTAssertEqual(union.find(node: clusterNode1), clusterNode1)
        XCTAssertEqual(union.find(node: clusterNode2), clusterNode3)
    }
    
    func testSut_ShouldCompressPath() {
        
        let clusterNode0 = ClusterNode(node: 0, id: 0,rank: 0,leader: 0)
        let clusterNode1 = ClusterNode(node: 1, id: 1,rank: 0,leader: 4)
        let clusterNode2 = ClusterNode(node: 2, id: 2, rank: 0, leader: 5)
        let clusterNode3 = ClusterNode(node: 3, id: 3, rank: 0, leader: 5)
        let clusterNode4 = ClusterNode(node: 4, id: 4, rank: 1, leader: 6)
        let clusterNode5 = ClusterNode(node: 5, id: 5, rank: 1, leader: 7)
        let clusterNode6 = ClusterNode(node: 6, id: 6, rank: 2, leader: 7)
        let clusterNode7 = ClusterNode(node: 7, id: 7, rank: 3, leader: 7)
        
        var union = NCUnionFind(inputNodes: [0,1,2,3,4,5,6,7])
        union.clusters = [clusterNode0,
                          clusterNode1,
                          clusterNode2,
                          clusterNode3,
                          clusterNode4,
                          clusterNode5,
                          clusterNode6,
                          clusterNode7]
        
        XCTAssertEqual(union.find(clusterID: 1)?.id, 7)
        XCTAssertEqual(clusterNode1.leader, 7)
        XCTAssertEqual(clusterNode4.leader, 7)
    }
}
