//
//  PokemonDecodingTest.swift
//  PokemonTests
//
//  Created by 정원기 on 2021/01/11.
//

import XCTest
@testable import Pokemon

import RxSwift
import RxBlocking

class PokemonMetadataServerDataSourceTests: XCTestCase {
    var requester = TestJsonRequester()
    lazy var dataSource = PokemonMetadataServerDataSource(jsonRequester: requester)
    
    override func setUp() {
        super.setUp()
        
        requester.clear()
    }
    
    func test_decoding() throws {
        requester.testJson = ["pokemons": [
              ["id": 1, "names": ["이상해씨", "Bulbasaur"]],
              ["id": 2, "names": ["이상해풀"]],
              ["id": 3, "names": ["이상해꽃", "Venusaur", "TestName1", "TestName2"]],
              ["id": 4, "names": ["파이리"]],
              ["id": 5, "names": ["리자드", "Charmeleon"]]
        ]]
        
        let fetch = dataSource.fetchNames()
        let models = try fetch.toBlocking().single()
        
        XCTAssertEqual(models.count, 5)
        XCTAssertEqual(models.map { $0.id }, [1, 2, 3, 4, 5])
        XCTAssertEqual(models.map { $0.representativeName }, ["이상해씨", "이상해풀", "이상해꽃", "파이리", "리자드"])
        XCTAssertEqual(models.map { $0.otherNames.first }, ["Bulbasaur", nil, "Venusaur", nil, "Charmeleon"])
        XCTAssertEqual(models[2].otherNames, ["Venusaur", "TestName1", "TestName2"])
    }
    
    func test_excludes_empty_names_array() throws {
        requester.testJson = ["pokemons": [
            ["id": 1, "names": ["이상해씨", "Bulbasaur"]],
            ["id": 2, "names": []],
            ["id": 3],
            ["id": 4, "names": ["파이리", "Charmander"]],
            ["id": 5, "names": ["리자드", "Charmeleon"]]
        ]]
        
        let fetch = dataSource.fetchNames()
        let models = try fetch.toBlocking().single()
        
        XCTAssertEqual(models.count, 3)
        XCTAssertEqual(models.map { $0.id }, [1, 4, 5])
        XCTAssertEqual(models.map { $0.representativeName }, ["이상해씨", "파이리", "리자드"])
    }
    
    func test_missing_pokemons_field() throws {
        requester.testJson = ["invalid": [
            ["id": 1, "names": ["이상해씨", "Bulbasaur"]],
            ["id": 2, "names": ["이상해풀"]],
            ["id": 3, "names": ["이상해꽃", "Venusaur", "TestName1", "TestName2"]],
            ["id": 4, "names": ["파이리"]],
            ["id": 5, "names": ["리자드", "Charmeleon"]]
        ]]
        
        let fetch = dataSource.fetchNames()
        
        XCTAssertThrowsError(try fetch.toBlocking().single())
    }
    
    func test_empty_pokemons_field() throws {
        requester.testJson = ["pokemons" : []]
        
        let fetch = dataSource.fetchNames()
        let model = try fetch.toBlocking().single()
        
        XCTAssertTrue(model.isEmpty)
    }
}

class TestJsonRequester: JsonRequestable {
    var testJson: Any?
    
    func request(url: URL) -> Single<Any> {
        if let testJson = testJson {
            return .just(testJson)
        } else {
            return .error(TestError.emptyJson)
        }
    }
    
    func clear() {
        testJson = nil
    }
    
    enum TestError: Error {
        case emptyJson
    }
}
