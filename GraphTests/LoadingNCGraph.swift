//
//  DataLoading.swift
//  NCGraphTests
//
//  Created by Nikita Gromadskyi on 11/1/16.
//  Copyright © 2016 Nikita Gromadskyi. All rights reserved.
//

import XCTest
import NCGraph

extension XCTestCase {
    
    /// Helper method for loading graph from file
    func loadNCGraph(form: GraphForm, isDirected: Bool, allowParallel: Bool) -> NCGraph<NCNode, NCEdge> {
        
        var data = [String]()
        var sut = NCGraph<NCNode, NCEdge>(isDirected: isDirected, allowParallelEdges: allowParallel)
        
        switch form {
        case .comleteGraph:
          data = loadDataFrom(fileName: "gComplete")
          loadWeighted(data: &data, sut: &sut)
        case .negWeighted:
            data = loadDataFrom(fileName: "gNegWeighted")
            loadWeighted(data: &data, sut: &sut)
        case .negWeightedMed:
            data = loadDataFrom(fileName: "gNegWeightedMed")
            loadWeighted(data: &data, sut: &sut)
        case .negCycle:
            data = loadDataFrom(fileName: "gNegCycle")
            loadWeighted(data: &data, sut: &sut)
        case .posWeighted:
            data = loadDataFrom(fileName: "gAdjListPos")
            loadAdjList(data: &data, sut: &sut)
        }
        return sut
    }
    
    
    /// load graph from file
    private func loadDataFrom(fileName: String) -> [String] {
        let bundle = Bundle(for: GraphTests.self)
        var data = [String]()
        if let url = bundle.url(forResource: fileName, withExtension: "txt") {
            do {
                data = try String(contentsOf: url, encoding: String.Encoding.utf8).components(separatedBy: CharacterSet.newlines)
            } catch let err as NSError {
                print(err)
            }
        } else {
            print("File not found")
        }
        return data
    }
    
    /// add data to graph
    private func loadWeighted(data:inout [String], sut: inout NCGraph<NCNode, NCEdge>) {
        data.removeFirst() // remove info
        for edge in data {
            let edgeInfo = edge.components(separatedBy: CharacterSet.whitespaces)
            assert(edgeInfo.count == 3)
            assert(sut.addEdge(NCEdge(tailName: edgeInfo[0], headName: edgeInfo[1], weight: Int(edgeInfo[2])!)))
        }
    }
    
    private func loadAdjList(data: inout [String], sut: inout NCGraph<NCNode, NCEdge>) {
        
        for edge in data {
            
            var edgesInfo = edge.components(separatedBy: CharacterSet.whitespaces)
            let tail = edgesInfo.removeFirst()
            edgesInfo.forEach({ (headNWeight) in
                let edgeInfo = headNWeight.components(separatedBy: CharacterSet.punctuationCharacters)
                assert(sut.addEdgeWith(tailName: tail, headName: edgeInfo[0], weight: Int(edgeInfo[1])!))
            })
        }
    }
    
}

public enum GraphForm {
    /// complete with positive edge weights
    case comleteGraph
    /// weighter graph with negative edge weights
    case negWeighted
    /// negative weighted graph, medium (n == 1000)
    case negWeightedMed
    /// newgative weighted graph with negative cycle
    case negCycle
    /// positive weighted, small (n == 200)
    case posWeighted
    
}
