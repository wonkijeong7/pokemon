//
//  PokemonRemoteDataSourceTests.swift
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

class PokemonServerDataSourceTests: XCTestCase {
    var requester = TestJsonRequester()
    lazy var dataSource = PokemonServerDataSource(jsonRequester: requester)
    
    override func setUp() {
        super.setUp()
        
        requester.clear()
    }
    
    func test_decoding() throws {
        let expectedUrl = "https://www.kakaomobility.com/"
        requester.testJson = [
            "id": 1,
            "height": 6,
            "weight": 40,
            "sprites": [
                "front_default": expectedUrl
            ]
        ]
        
        let fetch = dataSource.pokemon(id: 1)
        let model = try fetch.toBlocking().single()
        
        XCTAssertEqual(model.id, 1)
        XCTAssertEqual(model.height, 6)
        XCTAssertEqual(model.weight, 40)
        XCTAssertEqual(model.thumbnailUrl?.absoluteString, expectedUrl)
    }
    
    func test_thumbnailUrl_is_nil_when_invalid_string() throws {
        requester.testJson = [
            "id": 1,
            "height": 6,
            "weight": 40,
            "sprites": [
                "front_default": "\\"
            ]
        ]
        
        let fetch = dataSource.pokemon(id: 1)
        let model = try fetch.toBlocking().single()
        
        XCTAssertEqual(model.id, 1)
        XCTAssertEqual(model.height, 6)
        XCTAssertEqual(model.weight, 40)
        XCTAssertNil(model.thumbnailUrl)
    }
    
    func test_thumbnailUrl_when_front_default_is_empty() throws {
        let expectedUrl = "https://www.kakaomobility.com/"
        requester.testJson = [
            "id": 1,
            "height": 6,
            "weight": 40,
            "sprites": [
                "invalid_url1": "\\",
                "invalid_url2": "",
                "invalid_url3": "",
                "value_url": expectedUrl,
            ]
        ]
        
        let fetch = dataSource.pokemon(id: 1)
        let model = try fetch.toBlocking().single()
        
        XCTAssertEqual(model.id, 1)
        XCTAssertEqual(model.height, 6)
        XCTAssertEqual(model.weight, 40)
        XCTAssertEqual(model.thumbnailUrl?.absoluteString, expectedUrl)
    }
    
    func test_thumbnailUrl_when_invalid_sprites_field() throws {
        // sprites 필드가 String:String이 아닌 어떤 형태이더라도 valid한 한 가지 url을 가져오도록 하는 것이 맞지만
        // 이를 만족시키려면 구현해야 할 것이 많아, 일단 String:String 형태가 아닌 경우에는 thumbnailUrl을 nil로 취급한다.
        
        let expectedUrl = "https://www.kakaomobility.com/"
        requester.testJson = [
            "id": 1,
            "height": 6,
            "weight": 40,
            "sprites": [
                "invalid_url1": "\\",
                "invalid_url2": 1,
                "invalid_url3": ["1", "2", "3"],
                "value_url": expectedUrl,
            ]
        ]
        
        let fetch = dataSource.pokemon(id: 1)
        let model = try fetch.toBlocking().single()
        
        XCTAssertEqual(model.id, 1)
        XCTAssertEqual(model.height, 6)
        XCTAssertEqual(model.weight, 40)
        XCTAssertNil(model.thumbnailUrl)
    }
}

class PokemonLocationServerDataSourceTests: XCTestCase {
    var requester = TestJsonRequester()
    lazy var dataSource = PokemonLocationServerDataSource(jsonRequester: requester)
    
    override func setUp() {
        super.setUp()
        
        requester.clear()
    }
    
    func test_decoding() throws {
        requester.testJson = ["pokemons": [
            ["lat":37.394919, "lng": 127.111138, "id": 1],
            ["lat":37.378402, "lng": 127.114361, "id": 1],
            ["lat":37.370507, "lng": 127.119276, "id": 1],
            ["lat":37.374309, "lng": 127.127585, "id": 1],
            ["lat":37.375699, "lng": 127.149718, "id": 1],
            ["lat":37.394328, "lng": 127.110408, "id": 7],
            ["lat":37.295599, "lng": 127.075105, "id": 7],
            ["lat":37.412829, "lng": 127.112327, "id": 7],
            ["lat":37.394317, "lng": 127.108250, "id": 7],
            ["lat":37.392340, "lng": 127.118345, "id": 7],
            ["lat":37.389459, "lng": 127.111940, "id": 7],
            ["lat":37.500059, "lng": 127.026922, "id": 25],
            ["lat":37.426700, "lng": 127.108434, "id": 25],
            ["lat":37.360164, "lng": 126.988073, "id": 25],
            ["lat":37.331506, "lng": 127.107377, "id": 25],
            ["lat":37.350613, "lng": 127.173124, "id": 25],
            ["lat":37.401250, "lng": 127.110660, "id": 52],
            ["lat":37.388538, "lng": 127.083208, "id": 143],
            ["lat":37.333621, "lng": 127.051043, "id": 143],
            ["lat":37.325431, "lng": 127.074904, "id": 143]
        ]]
        
        let fetch = dataSource.fetchKnownLocations()
        let models = try fetch.toBlocking().single()
        
        XCTAssertEqual(models.count, 5)
        XCTAssertEqual(models[1]?.count, 5)
        XCTAssertEqual(models[7]?.count, 6)
        XCTAssertEqual(models[25]?.count, 5)
        XCTAssertEqual(models[52]?.count, 1)
        XCTAssertEqual(models[143]?.count, 3)
    }
    
    func test_excludes_invalid_elements() throws {
        requester.testJson = ["pokemons": [
            ["lat":37.394919, "lng": 127.111138, "id": 1],
            ["lat":37.378402, "lng": 127.114361, "id": 1],
            ["id": 1],
            ["lat":37.394328],
            ["lng":127.075105, "id": 7],
            ["lat":37.500059, "lng": 127.026922, "id": 25],
            ["lat":37.426700, "lng": 127.108434, "id": "invalid"],
            ["lat":37.426700, "lng": "invalid", "id": 25],
        ]]
        
        let fetch = dataSource.fetchKnownLocations()
        let models = try fetch.toBlocking().single()
        
        XCTAssertEqual(models.count, 2)
        XCTAssertEqual(models[1]?.count, 2)
        XCTAssertNil(models[7])
        XCTAssertEqual(models[25]?.count, 1)
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
