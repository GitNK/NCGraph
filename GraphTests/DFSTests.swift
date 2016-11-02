//
//  DFSTests.swift
//  NCGraphTests
//
//  Created by Nikita Gromadskyi on 10/22/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import XCTest
@testable import NCGraph

class DFSTests: XCTestCase {
    
    var sut: NCGraph<NCNode,NCEdge>!
    
    override func setUp() {
        super.setUp()
        sut = NCGraph<NCNode,NCEdge>(isDirected: true, allowParallelEdges: true)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTopSort_ShouldReturnTopSorted() {
        
        let edge_1 = NCEdge(tailName: "s", headName: "v")
        let edge_2 = NCEdge(tailName: "s", headName: "w")
        let edge_3 = NCEdge(tailName: "v", headName: "t")
        let edge_4 = NCEdge(tailName: "w", headName: "t")
        
        sut.addEdgesFrom(array: [edge_1, edge_2, edge_3, edge_4])
        
        guard let sorted = sut.topSort() else {
            fatalError()
        }
        
        XCTAssertTrue(sorted == [NCNode(name:"s"),NCNode(name:"w"), NCNode(name:"v"), NCNode(name:"t")] || sorted == [NCNode(name:"s"),NCNode(name:"v"), NCNode(name:"w"), NCNode(name:"t")] )
    }
    
    func testTopSort_ShouldReturnTopSorted2() {
        
        let edge_5 = NCEdge(tailName: "1", headName: "2")
        let edge_4 = NCEdge(tailName: "2", headName: "3")
        let edge_3 = NCEdge(tailName: "3", headName: "4")
        let edge_2 = NCEdge(tailName: "4", headName: "5")
        let edge_1 = NCEdge(tailName: "5", headName: "6")
        
        sut.addEdgesFrom(array: [edge_1, edge_2, edge_3, edge_4, edge_5])
        
        XCTAssertTrue(sut.isDAG)
        
        guard let sorted = sut.topSort() else {
            fatalError()
        }
        
        XCTAssertEqual(sorted, [NCNode(name:"1"), NCNode(name:"2"),
                                NCNode(name:"3"), NCNode(name:"4"),
                                NCNode(name: "5"), NCNode(name: "6")])
        
    }
    
    func testTopSort_ShouldReturnNilOnCyclicGraph(){
        let edge_1 = NCEdge(tailName: "s", headName: "v")
        let edge_2 = NCEdge(tailName: "w", headName: "s")
        let edge_3 = NCEdge(tailName: "v", headName: "t")
        let edge_4 = NCEdge(tailName: "t", headName: "w")
        
        sut.addEdgesFrom(array: [edge_1, edge_2, edge_3, edge_4])
        
        XCTAssertNil(sut.topSort())
    }
    
    func testTopSort_ShouldReturnNilOnEmptyGraph() {
        
        XCTAssertNil(sut.topSort())
    }
    
    func testIsDAG_OnAcyclicGraph_True() {
        
        let edge_1 = NCEdge(tailName: "s", headName: "v")
        let edge_2 = NCEdge(tailName: "s", headName: "w")
        let edge_3 = NCEdge(tailName: "v", headName: "t")
        let edge_4 = NCEdge(tailName: "w", headName: "t")
        
        sut.addEdgesFrom(array: [edge_1, edge_2, edge_3, edge_4])
        
        XCTAssertTrue(sut.isDAG)
    }
    
    func testIsDAG_OnCyclicGraph_False() {
        
        let edge_1 = NCEdge(tailName: "s", headName: "v")
        let edge_2 = NCEdge(tailName: "w", headName: "s")
        let edge_3 = NCEdge(tailName: "v", headName: "t")
        let edge_4 = NCEdge(tailName: "t", headName: "w")
        
        sut.addEdgesFrom(array: [edge_1, edge_2, edge_3, edge_4])
        
        XCTAssertFalse(sut.isDAG)
    }
    
    func testSCC_ShouldReturnSCCs() {
        
        let edge_1 = NCEdge(tailName: "1", headName: "7")
        let edge_2 = NCEdge(tailName: "7", headName: "4")
        let edge_3 = NCEdge(tailName: "7", headName: "9")
        let edge_4 = NCEdge(tailName: "9", headName: "6")
        let edge_5 = NCEdge(tailName: "6", headName: "3")
        let edge_6 = NCEdge(tailName: "3", headName: "9")
        let edge_7 = NCEdge(tailName: "6", headName: "8")
        let edge_8 = NCEdge(tailName: "8", headName: "2")
        let edge_9 = NCEdge(tailName: "2", headName: "5")
        let edge_10 = NCEdge(tailName: "5", headName: "8")
        let edge_11 = NCEdge(tailName: "4", headName: "1")
        
        sut.addEdgesFrom(array: [edge_1,edge_2,edge_3,
                                 edge_4,edge_5,edge_6,
                                 edge_7,edge_8,edge_9,
                                 edge_10, edge_11])
        let sccs = sut.scc()
        XCTAssertEqual(sccs?.count, 3)
        
    }
    
    func testSCC_SCCofPath_is6() {
        
        let edge_5 = NCEdge(tailName: "1", headName: "2")
        let edge_4 = NCEdge(tailName: "2", headName: "3")
        let edge_3 = NCEdge(tailName: "3", headName: "4")
        let edge_2 = NCEdge(tailName: "4", headName: "5")
        let edge_1 = NCEdge(tailName: "5", headName: "6")
        
        sut.addEdgesFrom(array: [edge_1, edge_2, edge_3, edge_4, edge_5])
        
        XCTAssertTrue(sut.isDAG)
        
        guard let sccs = sut.scc() else {
            fatalError()
        }
        
        XCTAssertEqual(sccs.count, 6)
    }
    
    func testTopSortPerformance() {
        
        sut = loadNCGraph(form: .comleteGraph, isDirected: true, allowParallel: true)
        
        self.measure {
            XCTAssertNotNil(self.sut.topSort())
        }
    }
    
    func testIsAcyclicPerformance() {
        
        sut = loadNCGraph(form: .comleteGraph, isDirected: true, allowParallel: true)
        
        self.measure {
            XCTAssertTrue(self.sut.isDAG)
        }
    }
    
    func testSCCPerformance() {
        
        sut = loadNCGraph(form: .comleteGraph, isDirected: true, allowParallel: true)
        
        self.measure {
            XCTAssertNotNil(self.sut.scc())
        }
    }
}
