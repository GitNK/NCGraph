//
//  ClusteringTests.swift
//  NCGraphTests
//
//  Created by Nikita Gromadskyi on 10/21/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import XCTest
@testable import NCGraph

class ClusteringTests: XCTestCase {
    
    var sut: NCGraph<NCNode, NCEdge>!
    
    override func setUp() {
        sut = loadNCGraph(form: .comleteGraph, isDirected: false, allowParallel: true)
        super.setUp()
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testMaxSpacing_MaximumSpacingOf4Clustering_Is_106() {
        
        XCTAssertEqual(self.sut.nodeCount, 500)
        XCTAssertEqual(self.sut.kClusteringMaxSpacing(k: 4), 106)
    }
}
