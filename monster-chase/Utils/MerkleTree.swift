//
//  MerkleTree.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/24/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation

public typealias MerkleTreeHashFunction = (_ element: Data) -> Data?
public class MerkleTree {
    
    var layers:[[Data]] = [[Data]]()
    let hashFunction:MerkleTreeHashFunction
    public var sorted:Bool = false
    
    // Public interface
    public init(elements: [Data], hashFunction: @escaping MerkleTreeHashFunction, sort: Bool = true) {
        self.hashFunction = hashFunction
        self.sorted = sort
        self.layers = generateLayers(elements: elements)
    }
    
    public func getRoot() -> Data {
        return self.layers[self.layers.count - 1][0]
    }
    
    public func getLayers() -> [[Data]] {
        return self.layers
    }
    
    public func getLayersHex() -> [[String]] {
        return self.layers.reduce(into: [[String]](), { (result, currLayer) in
            let currLayerStr = currLayer.map({ (currData) -> String in
                return currData.toHexString()
            })
            result.append(currLayerStr)
        })
    }
    
    public func getProof(leaf: Data) -> [Data] {
        guard var index = getLeaves().index(of: leaf) else {
            return [Data]()
        }
        return self.layers.reduce(into: [Data](), { (proof, currLayer) in
            if let pairElement = getPairElement(index: index, layer: currLayer) {
                proof.append(pairElement)
            }
            
            index = index / 2
        })
    }
    
    // Internal functions
    func getPairElement(index: Int, layer: [Data]) -> Data? {
        let pairIndex = index % 2 == 0 ? index + 1 : index - 1
        var result:Data?
        if pairIndex < layer.count {
            result = layer[pairIndex]
        }
        return result
    }
    
    func getLeaves() -> [Data] {
        return self.layers[0]
    }
    
    func generateLayers(elements: [Data]) -> [[Data]] {
        var layers = [[Data]]()
        var leaves = elements.map({ (element) -> Data in
            if let hashedElem = self.hashFunction(element) {
                return hashedElem
            } else {
                return Data()
            }
        })
        
        // Filter out empty leaves
        leaves = leaves.filter({ (element) -> Bool in
            return !element.isEmpty
        })
        
        // Sort leaves
        if self.sorted {
            leaves = leaves.sorted(by: dataComparison)
        }
        
        // Append leaves
        layers.append(leaves)
        
        var currentLayer = layers[layers.count - 1]
        while currentLayer.count > 1 {
            layers.append(hashPairs(elements: currentLayer))
            currentLayer = layers[layers.count - 1]
        }
        
        return layers
    }
    
    func hashPairs(elements: [Data]) -> [Data] {
        return elements.reduce(into: [Data](), { (result, currElem) in
            var index:Int = 0
            if let elemIndex = elements.index(of: currElem) {
                index = elemIndex
            }
            if index % 2 == 0 {
                var nextElem:Data = Data()
                if self.sorted {
                    nextElem = sortAndConcat(elem: currElem, nextElem: elements[index + 1])
                } else {
                    nextElem.append(nextElem)
                    nextElem.append(elements[index + 1])
                }
                if let hashedElem = self.hashFunction(nextElem) {
                    result.append(hashedElem)
                }
            }
        })
    }
    
    func sortAndConcat(elem: Data, nextElem: Data) -> Data {
        let sortedElements = [elem, nextElem].sorted(by: dataComparison)
        return sortedElements.reduce(into: Data(), { (result, currElem) in
            result.append(currElem)
        })
    }
    
    // Should return true if x < y
    public func dataComparison(x: Data, y: Data) -> Bool {
        return x.toHexString() < y.toHexString()
    }
}
