//
//  NCBinaryHeapTests.swift
//  NCGraphTests
//
//  Created by Nikita Gromadskyi on 7/3/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import XCTest
@testable import NCGraph

class BinaryHeapTests: XCTestCase {
    
    var sut: NCBinaryHeap<Int>!
    
    override func setUp() {
        super.setUp()
        sut = NCBinaryHeap<Int>()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInit_ShouldCreateEmptyHeap() {
        
        let heap: NCBinaryHeap = NCBinaryHeap<String>()
        XCTAssertNotNil(heap)
        XCTAssertEqual(heap.count, 0)
    }
    
    
    func testPush_AfterAddingOneItem_IsOne() {
        
        sut.push(1)
        XCTAssertEqual(sut.count, 1)
    }
    
    func testPop_ShouldPopPreviouslyAddedItem() {
     
        sut.push(1)
        guard let popped = sut.pop() else {
            XCTFail()
            return
        }
       XCTAssertEqual(popped, 1)
    }
    
    func testPop_ShouldPopMinValueItem() {
        
        let input = [4,4,8,9,4,12,9,11,13]
        for i in input {
            sut.push(i)
        }
        print("Description before pop: \(sut.description())")
        guard let popped = sut.pop() else {
            XCTFail()
            return
        }
        print("Description after pop: \(sut.description())")
        XCTAssertEqual(popped, input.min())
    }
    
    func testPop_PoppedItemShouldBeRemoved() {
        
        sut.push(33)
        _ = sut.pop()
        XCTAssertTrue(sut.count == 0)
    }
    
    func testPeek_ShouldNotDeleteMinValueItem() {
        
        for i in (1...10).reversed() {
            sut.push(i)
        }
        let count = sut.count
        
        XCTAssertEqual((1...10).min(), sut.peak())
        XCTAssertEqual(sut.count, count)
    }
    
    func testSut_ShouldCorrectlyHeapifyArray() {
        
        let inputArray = Array((3...15).reversed())
        
        let heap = NCBinaryHeap<Int>(input: inputArray)
        
        XCTAssertEqual(heap.count, inputArray.count)
        XCTAssertEqual(heap.peak(), inputArray.min())
        print("Heapified: \(heap.description())")
    }
    
    func testIndexOf_ShouldReturnIndexOfElement() {
        
        for i in (1...10).reversed() {
            sut.push(i)
        }
        
        XCTAssertNotNil(sut.indexOf(3))
        print(sut.description())
        print(sut.indexOf(3)!)
    }
    
    func testDeleteAt_ShouldDeleteElementAtGivenIndex() {
        
        for i in (1...10).reversed() {
            sut.push(i)
        }
        print("Before delete: \(sut.description())")
        XCTAssertTrue((sut.remove(at: sut.indexOf(3)!) != nil))
        XCTAssertEqual(sut.count, (1...10).count-1)
        print("After delete: \(sut.description())")
    }
    
    func testPop_ShouldCorrectlyPopMinItem() {
    
        for i in (1...100).reversed() {
            sut.push(i)
        }
        var poppedArray  = Array<Int>()
        for _ in 1...100 {
            poppedArray.append(sut.pop()!)
        }
        XCTAssertEqual(Array<Int>(1...100), poppedArray)
    
    }
    
    func testSutPerformance_AddingBigArray() {
        
        self.measure {
            self.sut = NCBinaryHeap(input: Array(0..<1000000))
            
            let index = self.sut.indexOf(500000/2)
            XCTAssertEqual(self.sut.remove(at: index!), 500000/2)
        }
    }
}
