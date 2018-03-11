//
//  SPTests.swift
//  NCGraphTests
//
//  Created by Nikita Gromadskyi on 10/23/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import XCTest
@testable import NCGraph

class SPTests: XCTestCase {
    
    var sut: NCGraph<NCNode,NCEdge>!
    
    override func setUp() {
        super.setUp()
        
        sut = NCGraph(isDirected: true, allowParallelEdges: true)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //# MARK: - Dijkstra
    func testDijkstraSPPerformanceForGivenSources() {
        
        sut = loadNCGraph(form: .posWeighted, isDirected: true, allowParallel: true)
        
        self.measure {
            let spMap = self.sut.spFrom(source: NCNode(name: "1"), algorithm: .dijkstra)
            
            let sp_1 = spMap?["7"]; let sp_2 = spMap?["37"]; let sp_3 = spMap?["59"]
            let sp_4 = spMap?["82"]; let sp_5 = spMap?["99"]; let sp_6 = spMap?["115"]
            let sp_7 = spMap?["133"]; let sp_8 = spMap?["165"]; let sp_9 = spMap?["188"]
            let sp_10 = spMap?["197"]
            
            XCTAssertEqual(sp_1?.reduce(0){$0 + $1.weight}, 2599)
            XCTAssertEqual(sp_2?.reduce(0){$0 + $1.weight}, 2610)
            XCTAssertEqual(sp_3?.reduce(0){$0 + $1.weight}, 2947)
            XCTAssertEqual(sp_4?.reduce(0){$0 + $1.weight}, 2052)
            XCTAssertEqual(sp_5?.reduce(0){$0 + $1.weight}, 2367)
            XCTAssertEqual(sp_6?.reduce(0){$0 + $1.weight}, 2399)
            XCTAssertEqual(sp_7?.reduce(0){$0 + $1.weight}, 2029)
            XCTAssertEqual(sp_8?.reduce(0){$0 + $1.weight}, 2442)
            XCTAssertEqual(sp_9?.reduce(0){$0 + $1.weight}, 2505)
            XCTAssertEqual(sp_10?.reduce(0){$0 + $1.weight}, 3068)
        }
    }
    
    func testDijkstraSP_OnDegativeEdgeGraphShouldReturn_Nil() {
        
        XCTAssertTrue(sut.addEdgeWith(tailName: "1", headName: "2", weight: -10))
        XCTAssertTrue(sut.addEdgeWith(tailName: "2", headName: "3", weight: 2))
        XCTAssertTrue(sut.addEdgeWith(tailName: "3", headName: "4", weight: 3))
        XCTAssertTrue(sut.addEdgeWith(tailName: "4", headName: "1", weight: 3))
        XCTAssertTrue(sut.addEdgeWith(tailName: "2", headName: "5", weight: 5))
        XCTAssertTrue(sut.addEdgeWith(tailName: "3", headName: "5", weight: 7))
        
        XCTAssertNil(sut.spFrom(source: NCNode(name: "1"), algorithm: .dijkstra))
    }
    
    func testDijkstraPerformanceOnBigGraph() {
        
        sut = loadNCGraph(form: .comleteGraph, isDirected: true, allowParallel: true)
        
        self.measure {
            XCTAssertNotNil(self.sut.spFrom(source: NCNode(name: "48"), algorithm: .dijkstra))
        }
    }
    
    //# MARK: - BellmanFord
    func testBellmanFordSPPerformanceForGivenSources() {
        
        sut = loadNCGraph(form: .posWeighted, isDirected: true, allowParallel: true)
        
        self.measure {
            let spMap = self.sut.spFrom(source: NCNode(name: "1"), algorithm: .bellmanFord)
            
            let sp_1 = spMap?["7"]; let sp_2 = spMap?["37"]; let sp_3 = spMap?["59"]
            let sp_4 = spMap?["82"]; let sp_5 = spMap?["99"]; let sp_6 = spMap?["115"]
            let sp_7 = spMap?["133"]; let sp_8 = spMap?["165"]; let sp_9 = spMap?["188"]
            let sp_10 = spMap?["197"]
            
            
            XCTAssertEqual(sp_1?.reduce(0){ $0 + $1.weight }, 2599)
            XCTAssertEqual(sp_2?.reduce(0){ $0 + $1.weight }, 2610)
            XCTAssertEqual(sp_3?.reduce(0){ $0 + $1.weight }, 2947)
            XCTAssertEqual(sp_4?.reduce(0){ $0 + $1.weight }, 2052)
            XCTAssertEqual(sp_5?.reduce(0){ $0 + $1.weight }, 2367)
            XCTAssertEqual(sp_6?.reduce(0){ $0 + $1.weight }, 2399)
            XCTAssertEqual(sp_7?.reduce(0){ $0 + $1.weight }, 2029)
            XCTAssertEqual(sp_8?.reduce(0){ $0 + $1.weight }, 2442)
            XCTAssertEqual(sp_9?.reduce(0){ $0 + $1.weight }, 2505)
            XCTAssertEqual(sp_10?.reduce(0){ $0 + $1.weight }, 3068)
        }
    }
    
    func testBellmanFordPerformanceOnBigGraph() {
        
        sut = loadNCGraph(form: .comleteGraph, isDirected: true, allowParallel: true)
        
        self.measure {
            XCTAssertNotNil(self.sut.spFrom(source: NCNode(name: "48"), algorithm: .bellmanFord))
        }
    }
    
    func testBellmanFord_ShouldCalculateNegativeEdgeGraphSPs() {
        
        XCTAssertTrue(sut.addEdgeWith(tailName: "1", headName: "2", weight: -2))
        XCTAssertTrue(sut.addEdgeWith(tailName: "2", headName: "3", weight: -1))
        XCTAssertTrue(sut.addEdgeWith(tailName: "3", headName: "1", weight: 4))
        XCTAssertTrue(sut.addEdgeWith(tailName: "3", headName: "4", weight: -3))
        XCTAssertTrue(sut.addEdgeWith(tailName: "3", headName: "6", weight: 2))
        XCTAssertTrue(sut.addEdgeWith(tailName: "5", headName: "4", weight: -4))
        XCTAssertTrue(sut.addEdgeWith(tailName: "5", headName: "6", weight: 1))
        
        for node in sut.nodes() {
            assert(sut.addEdgeWith(tail: NCNode(name: "0"), head: node, weight: 0))
        }
        
        let sp = sut.spFrom(source: NCNode(name: "0"), algorithm: .bellmanFord)
        
        XCTAssertEqual(sp?["6"]!.reduce(0){ $0 + $1.weight }, -1)
    }
    
    func testBellmanFordPerformanceOnBiggerGraph() {
        
        sut = loadNCGraph(form: .negWeightedMed, isDirected: true, allowParallel: true)
        
        self.measure {
            let sp = self.sut.spFrom(source: NCNode(name: "48"), algorithm: .bellmanFord)
            XCTAssertNotNil(sp)
        }
    }
    
    func testBellmanFord_OnGraphWithNegativeCycleIs_Nil() {
        
        XCTAssertTrue(sut.addEdgeWith(tailName: "1", headName: "2", weight: -10))
        XCTAssertTrue(sut.addEdgeWith(tailName: "2", headName: "3", weight: 2))
        XCTAssertTrue(sut.addEdgeWith(tailName: "3", headName: "4", weight: 3))
        XCTAssertTrue(sut.addEdgeWith(tailName: "4", headName: "1", weight: 3))
        XCTAssertTrue(sut.addEdgeWith(tailName: "2", headName: "5", weight: 5))
        XCTAssertTrue(sut.addEdgeWith(tailName: "3", headName: "5", weight: 7))
        
        let spMap = self.sut.spFrom(source: NCNode(name: "1"), algorithm: .bellmanFord)
        XCTAssertNil(spMap)
    }
    
    
    func testBellmanFordCycleDetectPerformance() {
        
        sut = loadNCGraph(form: .negCycle, isDirected: true, allowParallel: true)
        
        self.measure {
            let spMap = self.sut.spFrom(source: NCNode(name: "1"), algorithm: .bellmanFord)
            XCTAssertNil(spMap)
        }
    }
    
    //# MARK: - Johnsons ASSP tests
    
    func testJohnsons_ShouldComputeASSP() {
        
        XCTAssertTrue(sut.addEdgeWith(tailName: "1", headName: "2", weight: -2))
        XCTAssertTrue(sut.addEdgeWith(tailName: "2", headName: "3", weight: -1))
        XCTAssertTrue(sut.addEdgeWith(tailName: "3", headName: "1", weight: 4))
        XCTAssertTrue(sut.addEdgeWith(tailName: "3", headName: "4", weight: -3))
        XCTAssertTrue(sut.addEdgeWith(tailName: "3", headName: "6", weight: 2))
        XCTAssertTrue(sut.addEdgeWith(tailName: "5", headName: "4", weight: -4))
        XCTAssertTrue(sut.addEdgeWith(tailName: "5", headName: "6", weight: 1))
        
        
        let spMap = self.sut.assp()!
        XCTAssertNotNil(spMap)
        XCTAssertEqual(spMap["1"]?["4"]?.reduce(0){ $0 + $1.weight }, -6)
    }
    
    func testJohnsonsNegativeCycleDetectPerformance() {
        
        sut = loadNCGraph(form: .negCycle, isDirected: true, allowParallel: true)
        
        self.measure {
            let spMap = self.sut.assp()
            XCTAssertNil(spMap)
        }
    }
}
