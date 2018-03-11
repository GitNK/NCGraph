//
//  NCBinaryHeap.swift
//  NCGraph
//
//  Created by Nikita Gromadskyi on 7/3/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import Foundation

/**
 Binary Heap Data Structure
 */
public struct NCBinaryHeap<Element:Comparable> {
    private var heap: Array<Element>
    
    public var count: Int {
        return self.heap.count
    }
    
    public init() {
        self.init(input: Array<Element>())
    }
    
    public init(input: Array<Element>){
        heap = input
        heapifyFrom(index: 0)
    }
    
    public func indexOf(_ element: Element) -> Int? {
        return heap.index(of: element)
    }
    
    public func description() -> String {
        return heap.description
    }
    
    public func peak() -> Element? {
        
        if self.heap.isEmpty {
            return nil
        }
        return heap[0]
    }

    public mutating func pop() -> Element? {
        
        if self.heap.isEmpty {
            return nil
        }
        
        let min = heap[0]
        if heap.count > 1 {
            heap.swapAt(0, heap.count-1)
        }
        heap.removeLast()
        bubbleDown(0)
        
        return min
    }
    
    public mutating func push(_ element: Element) {
        heap.append(element)
        bubbleUp(heap.count-1)
    }
    
    /// removes element from heap at given index, nil if index out of range
    public mutating func remove(at index: Int) -> Element? {
        if index >= heap.count {
            return nil
        }
        let removed = heap[index]
        if index == heap.count-1 {
            heap.removeLast()
        } else {
            heap.swapAt(index, heap.count-1)
            heap.removeLast()
            heapifyFrom(index: index/2)
        }
        return removed
    }
    /// removes all elements from 'self'
    public mutating func removeAll() {
        heap.removeAll()
    }
    
    //# MARK: - Private section
    
    /// bubbles up last element (if need to)
    private mutating func bubbleUp(_ index: Int) {
        if index == 0 {
            return
        }
        let parentIdx = (index - 1) / 2
        if heap[index] < heap[parentIdx] {
            heap.swapAt(index, parentIdx)
            bubbleUp(parentIdx)
        }
    }
    
    private mutating func bubbleDown(_ index: Int){
        
        let n = heap.count
        let leftChildIdx = 2 * index + 1
        let rightChildIdx = 2 * index + 2
        
        if leftChildIdx <= n - 1 {
            var m: Int
            if rightChildIdx > n - 1 || heap[leftChildIdx] <= heap[rightChildIdx]{
                m = leftChildIdx
            } else {
                m = rightChildIdx
            }
            if heap[index] > heap[m] {
                heap.swapAt(index, m)
                bubbleDown(m)
            }
        }
    }
    
    /// recursive heapify
    private mutating func heapifyFrom(index: Int){
        
        if (index + 1)*4 <= heap.count {
            heapifyFrom(index: 2*index+1)
            heapifyFrom(index: 2*index+2)
        }
        bubbleDown(index)
    }
}
