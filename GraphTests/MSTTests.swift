//
//  MSTTests.swift
//  NCGraphTests
//
//  Created by Nikita Gromadskyi on 11/1/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import XCTest
@testable import NCGraph

class MSTTests: XCTestCase {
    
    var sut: NCGraph<NCNode, NCEdge>!
    
    override func setUp() {
        super.setUp()
        sut = NCGraph<NCNode,NCEdge>(isDirected: false, allowParallelEdges: true)
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testPrimmsMST_ShouldEqualTo_7() {
        
        assert(sut.addEdge(NCEdge(tailName: "a", headName: "b", weight: 1)))
        assert(sut.addEdge(NCEdge(tailName: "a", headName: "c", weight: 4)))
        assert(sut.addEdge(NCEdge(tailName: "a", headName: "d", weight: 3)))
        assert(sut.addEdge(NCEdge(tailName: "b", headName: "d", weight: 2)))
        assert(sut.addEdge(NCEdge(tailName: "c", headName: "d", weight: 5)))
        
        let mst = sut.mst(using: .primms)

        XCTAssertEqual(mst?.count, 3)
        XCTAssertEqual(mst?.reduce(0){$0 + $1.weight}, 7)
    }
    
    func testPrimmsPerformance() {
        
        sut = loadNCGraph(form: .negWeighted, isDirected: false, allowParallel: true)
        
        self.measure {
            
            XCTAssertEqual(self.sut.mst(using: .primms)?.reduce(0){$0 + $1.weight}, -3612829)
        }
    }
    
    func testKruskalsMST_ShouldEqualTo_7() {
        
        var testGraph = NCGraph<NCNode,NCEdge>(isDirected: false, allowParallelEdges: true)
        
        assert(testGraph.addEdge(NCEdge(tailName: "a", headName: "b", weight: 1)))
        assert(testGraph.addEdge(NCEdge(tailName: "a", headName: "c", weight: 4)))
        assert(testGraph.addEdge(NCEdge(tailName: "a", headName: "d", weight: 3)))
        assert(testGraph.addEdge(NCEdge(tailName: "b", headName: "d", weight: 2)))
        assert(testGraph.addEdge(NCEdge(tailName: "c", headName: "d", weight: 5)))
        
        let mst = testGraph.mst(using: .kruskals)
        
        XCTAssertEqual(mst?.reduce(0){$0 + $1.weight} , 7)
        XCTAssertEqual(mst?.count, 3)
    }

    func testKruskalsPerformance() {
        
        sut = loadNCGraph(form: .negWeighted, isDirected: false, allowParallel: true)
        self.measure {
            
            let score = self.sut.mst(using: .kruskals)?.reduce(0){$0 + $1.weight}
            XCTAssertEqual(score, -3612829)
        }
    }
        
}
