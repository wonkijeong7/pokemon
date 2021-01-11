//
//  FailableDecodable.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation

// https://stackoverflow.com/questions/46344963/swift-jsondecode-decoding-arrays-fails-if-single-element-decoding-fails

struct FailableDecodable<Base: Decodable>: Decodable {
    let base: Base?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        self.base = try? container.decode(Base.self)
    }
}

struct FailableDecodableArray<Element: Decodable>: Decodable {
    var elements: [Element]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        var elements = [Element]()
        if let count = container.count {
            elements.reserveCapacity(count)
        }

        while !container.isAtEnd {
            if let element = try container
                .decode(FailableDecodable<Element>.self).base {

                elements.append(element)
            }
        }

        self.elements = elements
    }
}
