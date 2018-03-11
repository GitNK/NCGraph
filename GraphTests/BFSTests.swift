//
//  BFSTests.swift
//  NCGraphTests
//
//  Created by Nikita Gromadskyi on 10/20/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import XCTest
@testable import NCGraph

class BFSTests: XCTestCase {
    
    var sut: NCGraph<NCNode,NCEdge>!
    
    override func setUp() {
        super.setUp()
        sut = NCGraph(isDirected: false, allowParallelEdges: true)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNumOfHops_ShoudReturnNumberOfHops() {
        
        XCTAssertTrue(sut.addEdgeWith(tailName: "s", headName: "a", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "s", headName: "b", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "a", headName: "c", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "b", headName: "c", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "b", headName: "d", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "c", headName: "e", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "c", headName: "d", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "d", headName: "e", weight: 0))
        
        XCTAssertEqual(sut.numOfHops(from: NCNode(name: "s"), to: NCNode(name: "e")), 3)
    }
    
    func testCC_ShoudReturnConnectedComponents() {
        
        XCTAssertTrue(sut.addEdgeWith(tailName: "s", headName: "a", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "s", headName: "b", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "a", headName: "c", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "b", headName: "c", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "b", headName: "d", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "c", headName: "e", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "c", headName: "d", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "d", headName: "e", weight: 0))
        
        XCTAssertEqual(sut.connectedComponents()?.count, 1)
        XCTAssertTrue(sut.isConnected)
    }
    
    func testCC_ShoudReturnConnectedComponents2() {
        
        XCTAssertTrue(sut.addEdgeWith(tailName: "1", headName: "3", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "1", headName: "5", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "3", headName: "5", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "5", headName: "7", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "5", headName: "9", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "2", headName: "4", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "6", headName: "8", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "8", headName: "10", weight: 0))
        XCTAssertTrue(sut.addEdgeWith(tailName: "10", headName: "6", weight: 0))
        
        guard let ccs = sut.connectedComponents() else {
            fatalError()
        }
        
        XCTAssertFalse(sut.isConnected)
        
        XCTAssertEqual(ccs.count, 3)
    }
    
    func testIsConnectedPerformance() {
        
        sut = loadNCGraph(form: .comleteGraph, isDirected: true, allowParallel: true)
        
        sut.isDirected = false
        
        self.measure {
            XCTAssertTrue(self.sut.isConnected)
        }
    }
}
