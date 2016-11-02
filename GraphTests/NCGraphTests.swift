//
//  NCGraphTests.swift
//  NCGraphTests
//
//  Created by Nikita Gromadskyi on 9/26/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import XCTest
@testable import NCGraph

class GraphTests: XCTestCase {
    
    var sut: NCGraph<NCNode,NCEdge>!
    
    override func setUp() {
        super.setUp()
        
        sut = NCGraph(isDirected: false, allowParallelEdges: true)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //# Mark: - Edge tests
    
    
    
    func testEdge_ShouldSetEdgeWeight() {
        
        let someEdge = NCEdge(tail: NCNode(name: "1"), head: NCNode(name: "2"), weight: 100)
        
        XCTAssertTrue(someEdge.weight == 100)
    }
    
    func testEdge_Equality() {
        
        let someEdge = NCEdge(tail: NCNode(name: "1"), head: NCNode(name: "2"))
        let someEdge2 = NCEdge(tail: NCNode(name: "1"), head: NCNode(name: "2"))
        
        XCTAssertEqual(someEdge, someEdge2)
    }
    
    func testEdge_NonEquality() {
        
        let someEdge = NCEdge(tail: NCNode(name: "1"), head: NCNode(name: "2"))
        let someEdge2 = NCEdge(tail: NCNode(name: "1"), head: NCNode(name: "3"))
        
        XCTAssertNotEqual(someEdge2, someEdge)
    }
    
    func testEdge_EdgeWithBiggerWeightShouldBeGreater() {
        
        let someEdge = NCEdge(tail: NCNode(name: "3"), head: NCNode(name: "2"), weight: 100)
        let someEdge2 = NCEdge(tail: NCNode(name: "5"), head: NCNode(name: "6"), weight: 40)
        
        XCTAssertTrue(someEdge > someEdge2)
        
    }
    
    func testNode_ShouldCreateNodeWithTitle() {
        
        let testTitle = "Test Title"
        let vertex = NCNode(name: testTitle)
        
        XCTAssertEqual(vertex.name, testTitle)
    }
    
    func testNode_NodesWithSameTitleShouldEqual() {
        
        let firstV = NCNode(name: "1")
        let firstV2 = NCNode(name: "1")
        
        XCTAssertEqual(firstV, firstV2)
    }
    
    func testSutInit_ShouldCreateAnEmptyGraph() {
        
        let emptyGraph = NCGraph<NCNode,NCEdge>(isDirected: false, allowParallelEdges: true)
        
        XCTAssertEqual(emptyGraph.edgeCount, 0)
        XCTAssertEqual(emptyGraph.nodeCount, 0)
    }
    
    func testNodeCount_AfterAddingOneNode_IsOne() {
        
        XCTAssertTrue(sut.addNode(NCNode(name: "bla")))
        XCTAssertTrue(sut.nodeCount == 1)
        
        XCTAssertTrue(sut.addEdge(NCEdge(tail: NCNode(name: "2"), head: NCNode(name: "1"))))
        XCTAssertEqual(sut.edgeCount, 1)
    }
    
    func testAddintSameNode_ShouldNotAddIt() {
        sut = NCGraph(isDirected: true, allowParallelEdges: false)
        let firstV = NCNode(name: "1")
        let firstV2 = NCNode(name: "1")
        
        XCTAssertTrue(sut.addNode(firstV))
        XCTAssertFalse(sut.addNode(firstV2))
        
        let secondV = NCNode(name: "2")
        let edge1 = NCEdge(tail: firstV, head: secondV)
        let edge2 = NCEdge(tail: firstV2, head: secondV)
        
        XCTAssertTrue(sut.addEdge(edge1))
        XCTAssertFalse(sut.addEdge(edge2))
    }
    
    func testAllowParallel_ShouldAddParallelEdge() {
        
        let firstV = NCNode(name: "1")
        let secondV = NCNode(name: "2")
        sut = NCGraph(isDirected: false, allowParallelEdges: true)
        let edge1 = NCEdge(tail: firstV, head: secondV)
        XCTAssertTrue(sut.addEdge(edge1))
        XCTAssertTrue(sut.addEdge(edge1))
    }
    
    func testContainse_ShouldContainAddedNodeAndEdge() {
        
        let node1 = NCNode(name: "1")
        let node2 = NCNode(name: "2")
        
        let edge = NCEdge(tail: node1, head: node2)
        
        XCTAssertTrue(sut.addEdge(edge))
        XCTAssertTrue(sut.containsNode(node1))
        XCTAssertTrue(sut.containsNode(node2))
        XCTAssertTrue(sut.containsEdge(edge))
    }
    
    func testAddNode_ShouldAddWithNodeName() {
        
        XCTAssertTrue(sut.addNode(NCNode(name: "1")))
        XCTAssertNotNil(sut.getNode(name: "1"))
        XCTAssertTrue(sut.containsNode(NCNode(name: "1")))
    }
    
    func testAddFrom_ShouldAddNodesFromArray() {
        
        let node1 = NCNode(name: "1")
        let node2 = NCNode(name: "2")
        let node3 = NCNode(name: "3")
        let node4 = NCNode(name: "4")
        
        sut.addNodesFrom(array: [node1, node2, node3, node4])
        
        XCTAssertTrue(sut.containsNode(node1))
        XCTAssertTrue(sut.containsNode(node2))
        XCTAssertTrue(sut.containsNode(node3))
        XCTAssertTrue(sut.containsNode(node4))
        
    }
    
    func testRemoveNode_ShouldRemoveNodeAndAdjacentToItEdges() {
        
        sut.isDirected = true
        
        let edge_1 = NCEdge(tailName: "1", headName: "2")
        let edge_2 = NCEdge(tailName: "1", headName: "3")
        let edge_3 = NCEdge(tailName: "2", headName: "3")
        
        let edge_4 = NCEdge(tailName: "2", headName: "1")
        let edge_5 = NCEdge(tailName: "3", headName: "1")
        let edge_6 = NCEdge(tailName: "3", headName: "2")
        
        sut.addEdgesFrom(array:[edge_1,edge_2,edge_3, edge_4, edge_5, edge_6])
        XCTAssertTrue(sut.removeNode(named: "1"))
        XCTAssertFalse(sut.containsNode(named: "1"))
        XCTAssertFalse(sut.containsEdge(edge_1))
        XCTAssertFalse(sut.containsEdge(edge_2))
        XCTAssertFalse(sut.containsEdge(edge_4))
        XCTAssertFalse(sut.containsEdge(edge_5))
    }
    
    func testRemoveAll_ShouldRemoveAllNodes() {
        
        sut.isDirected = true
        
        let edge_1 = NCEdge(tailName: "1", headName: "2")
        let edge_2 = NCEdge(tailName: "1", headName: "3")
        let edge_3 = NCEdge(tailName: "2", headName: "3")
        
        let edge_4 = NCEdge(tailName: "2", headName: "1")
        let edge_5 = NCEdge(tailName: "3", headName: "1")
        let edge_6 = NCEdge(tailName: "3", headName: "2")
        
        sut.addEdgesFrom(array:[edge_1,edge_2,edge_3, edge_4, edge_5, edge_6])
        sut.removeAll()
        XCTAssertTrue(sut.isEmpty)
        
        
        
    }
    
    func testAddEdge_ShouldAddEdgeWIthNodesTitle() {
        sut = NCGraph(isDirected: false, allowParallelEdges: false)
        XCTAssertTrue(sut.addEdge(NCEdge(tailName: "1", headName: "2")))
        let vertex1 = NCNode(name: "1")
        let vertex2 = NCNode(name: "2")
        XCTAssertFalse(sut.addEdge(NCEdge(tail: vertex1, head: vertex2)))
        XCTAssertTrue(sut.containsEdge(NCEdge(tail: vertex1, head: vertex2)))
    }
    
    func testWeight_ShouldComputeSumOfEdgesWeight() {
        
        XCTAssertTrue(sut.addEdge(NCEdge(tailName: "a", headName: "b", weight: 1)))
        XCTAssertTrue(sut.addEdge(NCEdge(tailName: "a", headName: "c", weight: 4)))
        XCTAssertTrue(sut.addEdge(NCEdge(tailName: "a", headName: "d", weight: 3)))
        XCTAssertTrue(sut.addEdge(NCEdge(tailName: "b", headName: "d", weight: 2)))
        XCTAssertTrue(sut.addEdge(NCEdge(tailName: "c", headName: "d", weight: 5)))
        XCTAssertEqual(sut.edgeCount, 5)
        XCTAssertEqual(sut.nodeCount, 4)
        XCTAssertEqual(sut.weight, 15)
    }
    
    
    func testSut_ShouldReturnExistingEdges() {
        
        sut = NCGraph(isDirected: true, allowParallelEdges: true)
        
        let edge_1 = NCEdge(tailName: "1", headName: "2", weight: 33)
        let edge_2 = NCEdge(tailName: "1", headName: "3")
        let edge_3 = NCEdge(tailName: "2", headName: "3")
        
        let edge_4 = NCEdge(tailName: "2", headName: "1")
        let edge_5 = NCEdge(tailName: "3", headName: "1")
        let edge_6 = NCEdge(tailName: "3", headName: "2")
        
        sut.addEdgesFrom(array:[edge_1,edge_2,edge_3, edge_4, edge_5, edge_6])
        
        XCTAssertTrue(sut.containsEdge(edge_1))
        XCTAssertTrue(sut.containsEdge(edge_2))
        XCTAssertTrue(sut.containsEdge(edge_3))
        XCTAssertTrue(sut.containsEdge(edge_4))
        XCTAssertTrue(sut.containsEdge(edge_5))
        XCTAssertTrue(sut.containsEdge(edge_6))
        
        let getEdge_1 = sut.getEdge(edge_1)
        let getEdge_5 = sut.getEdge(edge_5)
        XCTAssertEqual(getEdge_1, edge_1)
        XCTAssertEqual(getEdge_5, edge_5)
        XCTAssertNil(sut.getEdgeWith(tailName: "1", headName: "2"))
        
    }
    

    func testRemoveEdgesWith_ShouldRemoveAllEdgesWithNodeNames() {
        
        sut = NCGraph(isDirected: true, allowParallelEdges: true)
        
        let edge_1 = NCEdge(tailName: "1", headName: "2", weight: 33)
        let edge_2 = NCEdge(tailName: "1", headName: "3")
        let edge_3 = NCEdge(tailName: "2", headName: "3")
        
        let edge_4 = NCEdge(tailName: "2", headName: "1")
        let edge_5 = NCEdge(tailName: "3", headName: "1")
        let edge_6 = NCEdge(tailName: "3", headName: "2")
        
        sut.addEdgesFrom(array:[edge_1,edge_2,edge_3, edge_4, edge_5, edge_6])
        
        XCTAssertTrue(sut.containsEdge(edge_1))
        XCTAssertTrue(sut.containsEdge(edge_2))
        XCTAssertTrue(sut.containsEdge(edge_3))
        XCTAssertTrue(sut.containsEdge(edge_4))
        XCTAssertTrue(sut.containsEdge(edge_5))
        XCTAssertTrue(sut.containsEdge(edge_6))
        
        var removedEdges = sut.removeEdgesWith(tailName: "1", headName: "2")
        XCTAssertNotNil(removedEdges)
        XCTAssertEqual(removedEdges!, [edge_1])
        XCTAssertFalse(sut.containsEdge(edge_1))
        XCTAssertTrue(sut.containsEdge(edge_4))
        removedEdges = sut.removeEdgesWith(tailName: "2", headName: "1")
        XCTAssertEqual(removedEdges!, [edge_4])
        XCTAssertFalse(sut.containsEdge(edge_4))
        
    }
    
    func testRemoveEdgesWith_ShouldRemoveAllEdgesBetweenNodes_forUndirectedGraph() {
        
        sut = NCGraph(isDirected: false, allowParallelEdges: true)
        
        let edge_1 = NCEdge(tailName: "1", headName: "2", weight: 33)
        let edge_2 = NCEdge(tailName: "1", headName: "3")
        let edge_3 = NCEdge(tailName: "2", headName: "3")
        
        let edge_4 = NCEdge(tailName: "2", headName: "1")
        let edge_5 = NCEdge(tailName: "3", headName: "1")
        let edge_6 = NCEdge(tailName: "3", headName: "2")
        
        sut.addEdgesFrom(array:[edge_1,edge_2,edge_3, edge_4, edge_5, edge_6])
        
        XCTAssertTrue(sut.containsEdge(edge_1))
        XCTAssertTrue(sut.containsEdge(edge_2))
        XCTAssertTrue(sut.containsEdge(edge_3))
        XCTAssertTrue(sut.containsEdge(edge_4))
        XCTAssertTrue(sut.containsEdge(edge_5))
        XCTAssertTrue(sut.containsEdge(edge_6))
        
        let removedEdges = sut.removeEdgesWith(tailName: "1", headName: "2")
        XCTAssertNotNil(removedEdges)
        XCTAssertEqual(removedEdges!, [edge_1, edge_4])
        XCTAssertFalse(sut.containsEdge(edge_1))
        XCTAssertFalse(sut.containsEdge(edge_4))
        XCTAssertNil(sut.removeEdgesWith(tailName: "2", headName: "1"))
        
    }
    
    func testRemoveEdge_ShouldRemoveExistingEdge() {
        
        let edge1 = NCEdge(tailName: "a", headName: "b", weight: 1)
        let tail = NCNode(name: "a")
        let head = NCNode(name: "c")
        let edge2 = NCEdge(tail: tail, head: head, weight: 4)
        
        XCTAssertTrue(sut.addEdge(edge1))
        XCTAssertTrue(sut.addEdge(edge2))
        XCTAssertEqual(sut.edgeCount, 2)
        XCTAssertEqual(sut.removeEdgeWith(tailName: "a", headName: "b", weight: 1), edge1)
        XCTAssertEqual(sut.edgeCount, 1)
        XCTAssertEqual(sut.removeEdgeWith(tail: tail, head: head, weight: 4), edge2)
        XCTAssertEqual(sut.edgeCount, 0)
        
        let tailFromGraph = sut.getNode(name: tail.name)
        XCTAssertNotNil(tailFromGraph)
        XCTAssertFalse(sut.adjacentEdgesFor(node: tailFromGraph!)!.contains(edge1))
        
    }
    
    func testGetEdgesFor_ShouldReturnAllEdgesBetweenNodes() {
        
        sut = NCGraph(isDirected: false, allowParallelEdges: true)
        
        let edge1 = NCEdge(tailName: "a", headName: "b", weight: 1)
        let edge2 = NCEdge(tailName: "a", headName: "b", weight: 100)
        sut.addEdgesFrom(array: [edge1,edge2])
        
        XCTAssertEqual(sut.getEdgesFor(tailName: "a", headName: "b" )!, [edge1, edge2])
        XCTAssertNil(sut.getEdgesFor(tailName: "0", headName: "2"))
        
    }
    
    
    //# MARK: - Test directed graph
    
    func testInOutDegree_ShouldReturnInOutDegreeEdges() {
        
        sut.isDirected = true
        let edge_1 = NCEdge(tailName: "1", headName: "2")
        let edge_2 = NCEdge(tailName: "2", headName: "3")
        let edge_3 = NCEdge(tailName: "3", headName: "1")
        
        XCTAssertTrue(sut.addEdge(edge_1))
        XCTAssertTrue(sut.addEdge(edge_2))
        XCTAssertTrue(sut.addEdge(edge_3))
        
        XCTAssertEqual(sut.inDegreeEdgesFor(nodeNamed: "1")!, [edge_3])
        XCTAssertEqual(sut.inDegreeEdgesFor(nodeNamed: "3")!, [edge_2])
        XCTAssertEqual(sut.outDegreeEdgesFor(nodeNamed: "1")!, [edge_1])
        XCTAssertEqual(sut.outDegreeEdgesFor(nodeNamed: "3")!, [edge_3])
    }
    
    func testIsComplete_ShouldReturnTrueOnCompleteDigraph() {
        
        sut = NCGraph(isDirected: true, allowParallelEdges: true)
        
        let edge_1 = NCEdge(tailName: "1", headName: "2", weight: 1)
        let edge_2 = NCEdge(tailName: "1", headName: "3")
        let edge_3 = NCEdge(tailName: "2", headName: "3")
        
        let edge_4 = NCEdge(tailName: "2", headName: "1")
        let edge_5 = NCEdge(tailName: "3", headName: "1")
        let edge_6 = NCEdge(tailName: "3", headName: "2")
        
        sut.addEdgesFrom(array:[edge_1,edge_2,edge_3, edge_4, edge_5, edge_6])
        
        XCTAssertTrue(sut.isComplete)
        
        
    }
    
    func testIsComplete_ShouldReturnFalseOnNonCompleteDigraph() {
        
        sut = NCGraph(isDirected: true, allowParallelEdges: true)
        
        let edge_1 = NCEdge(tailName: "1", headName: "2", weight: 1)
        let edge_2 = NCEdge(tailName: "1", headName: "3")
        let edge_3 = NCEdge(tailName: "2", headName: "3")
        
        let edge_4 = NCEdge(tailName: "2", headName: "1")
        let edge_5 = NCEdge(tailName: "3", headName: "1")
        
        
        sut.addEdgesFrom(array:[edge_1,edge_2,edge_3, edge_4, edge_5])
        
        XCTAssertFalse(sut.isComplete)
        
        
    }
    
    // MARK: - Test unirected graph
    
    func testInOutDegree_ShouldReturnAdjacentEdgesForInOrOutDegree() {
        
        sut.isDirected = false
        let edge_1 = NCEdge(tailName: "1", headName: "2")
        let edge_2 = NCEdge(tailName: "2", headName: "3")
        let edge_3 = NCEdge(tailName: "3", headName: "1")
        
        XCTAssertTrue(sut.addEdge(edge_1))
        XCTAssertTrue(sut.addEdge(edge_2))
        XCTAssertTrue(sut.addEdge(edge_3))
        
        XCTAssertEqual(sut.inDegreeEdgesFor(nodeNamed: "1")!, [edge_3,edge_1])
        XCTAssertEqual(sut.inDegreeEdgesFor(nodeNamed: "2")!, [edge_1,edge_2])
        XCTAssertEqual(sut.inDegreeEdgesFor(nodeNamed: "3")!, [edge_2,edge_3])
        
        XCTAssertEqual(sut.outDegreeEdgesFor(nodeNamed: "1")!, [edge_3,edge_1])
        XCTAssertEqual(sut.outDegreeEdgesFor(nodeNamed: "2")!, [edge_1,edge_2])
        XCTAssertEqual(sut.outDegreeEdgesFor(nodeNamed: "3")!, [edge_2,edge_3])
    }
    
    func testIsComplete_OnCompleteGraph_True() {
        
        sut = NCGraph(isDirected: false, allowParallelEdges: false)
        
        let edge_1 = NCEdge(tailName: "1", headName: "2", weight: 1)
        let edge_2 = NCEdge(tailName: "1", headName: "3")
        let edge_3 = NCEdge(tailName: "2", headName: "3")
        
        sut.addEdgesFrom(array:[edge_1,edge_2,edge_3])
        
        XCTAssertTrue(sut.isComplete)
    }
    
    func testIsComplete_OnNonCompleteGraph_False() {
        
        sut = NCGraph(isDirected: false, allowParallelEdges: false)
        
        let edge_1 = NCEdge(tailName: "1", headName: "2")
        let edge_2 = NCEdge(tailName: "1", headName: "3")
        
        sut.addEdgesFrom(array:[edge_1,edge_2])
        
        XCTAssertFalse(sut.isComplete)
        
    }
    
    func testIsCompletePerformance() {
        
        sut = loadNCGraph(form: .comleteGraph, isDirected: false, allowParallel: true)
        
        self.measure {
            
            XCTAssertTrue(self.sut.isComplete)
        }
    }
    
    
    
}
