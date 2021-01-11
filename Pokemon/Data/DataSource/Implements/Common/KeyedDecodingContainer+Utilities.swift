//
//  KeyedDecodingContainer+Utilities.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/11.
//

import Foundation

extension KeyedDecodingContainer {
    func decodeString(forKey key: K) throws -> String {
        let stringValue = try decode(String.self, forKey: key)
        return stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func decodeStringIfPresent(forKey key: K) throws -> String? {
        guard contains(key) else { return nil }
        guard try !decodeNil(forKey: key) else { return nil }

        return try decodeString(forKey: key)
    }
    
    func decodeUrlIfPresent(forKey key: K) throws -> URL? {
        guard contains(key) else { return nil }
        guard try !decodeNil(forKey: key) else { return nil }
        
        let stringValue = try decode(String.self, forKey: key)
        let trimmedStringValue = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let url = URL(string: trimmedStringValue) else {
            return nil
        }
        
        return url
    }
}
