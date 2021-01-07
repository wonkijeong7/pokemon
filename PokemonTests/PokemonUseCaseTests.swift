//
//  PokemonUseCaseTests.swift
//  PokemonTests
//
//  Created by 정원기 on 2021/01/07.
//

import XCTest
@testable import Pokemon

import RxSwift
import RxTest
import RxBlocking

class PokemonUseCaseTests: XCTestCase {
    var nameRepository = TestNameRepository()

    override func setUp() {
        super.setUp()
        
        nameRepository.clear()
    }
    
    func test_search_in_single_name() throws {
        let names = [
            PokemonName(id: 1, representativeName: "이상해씨", otherNames: []),
            PokemonName(id: 2, representativeName: "이상해풀", otherNames: []),
            PokemonName(id: 3, representativeName: "이상해꽃", otherNames: []),
            PokemonName(id: 4, representativeName: "파이리", otherNames: []),
            PokemonName(id: 5, representativeName: "리자드", otherNames: []),
            PokemonName(id: 6, representativeName: "리자몽", otherNames: []),
            PokemonName(id: 7, representativeName: "꼬부기", otherNames: []),
            PokemonName(id: 8, representativeName: "어니부기", otherNames: []),
            PokemonName(id: 9, representativeName: "거북왕", otherNames: []),
            PokemonName(id: 10, representativeName: "캐터피", otherNames: [])
        ]
        
        nameRepository.designatedNames = names
        
        let searchUseCase = PokemonSearchDefaultUseCase(nameRepository: nameRepository)
        
        assertSearchResult(searchUseCase.search(keyword: "이상해"), expected: [1, 2, 3])
        assertSearchResult(searchUseCase.search(keyword: "리자"), expected: [5, 6])
        assertSearchResult(searchUseCase.search(keyword: "없음"), expected: [])
    }
    
    func test_search_in_multiple_name() throws {
        let names = [
            PokemonName(id: 1, representativeName: "이상해씨", otherNames: ["Bulbasaur"]),
            PokemonName(id: 2, representativeName: "이상해풀", otherNames: ["Ivysaur"]),
            PokemonName(id: 3, representativeName: "이상해꽃", otherNames: ["Venusaur", "test1"]),
            PokemonName(id: 4, representativeName: "파이리", otherNames: ["Charmander"]),
            PokemonName(id: 5, representativeName: "리자드", otherNames: ["Charmeleon", "test2"]),
            PokemonName(id: 6, representativeName: "리자몽", otherNames: ["Charizard"]),
            PokemonName(id: 7, representativeName: "꼬부기", otherNames: ["Squirtle", "test3"]),
            PokemonName(id: 8, representativeName: "어니부기", otherNames: ["Wartortle"]),
            PokemonName(id: 9, representativeName: "거북왕", otherNames: ["Blastoise", "test4"]),
            PokemonName(id: 10, representativeName: "캐터피", otherNames: ["Caterpie"])
        ]
        
        nameRepository.designatedNames = names
        
        let searchUseCase = PokemonSearchDefaultUseCase(nameRepository: nameRepository)
        
        assertSearchResult(searchUseCase.search(keyword: "saur"), expected: [1, 2, 3])
        assertSearchResult(searchUseCase.search(keyword: "리자"), expected: [5, 6])
        assertSearchResult(searchUseCase.search(keyword: "test"), expected: [3, 5, 7, 9])
        assertSearchResult(searchUseCase.search(keyword: "없음"), expected: [])
    }
    
    func test_search_case_insensitivity() throws {
        let names = [
            PokemonName(id: 1, representativeName: "이상해씨", otherNames: ["Bulbasaur"]),
            PokemonName(id: 2, representativeName: "이상해풀", otherNames: ["Ivysaur"]),
            PokemonName(id: 3, representativeName: "이상해꽃", otherNames: ["Venusaur", "test1"]),
            PokemonName(id: 4, representativeName: "파이리", otherNames: ["Charmander"]),
            PokemonName(id: 5, representativeName: "리자드", otherNames: ["Charmeleon", "test2"]),
            PokemonName(id: 6, representativeName: "리자몽", otherNames: ["Charizard"]),
            PokemonName(id: 7, representativeName: "꼬부기", otherNames: ["Squirtle", "test3"]),
            PokemonName(id: 8, representativeName: "어니부기", otherNames: ["Wartortle"]),
            PokemonName(id: 9, representativeName: "거북왕", otherNames: ["Blastoise", "test4"]),
            PokemonName(id: 10, representativeName: "캐터피", otherNames: ["Caterpie"])
        ]
        
        nameRepository.designatedNames = names
        
        let searchUseCase = PokemonSearchDefaultUseCase(nameRepository: nameRepository)
        
        assertSearchResult(searchUseCase.search(keyword: "CHAR"), expected: [4, 5, 6])
        assertSearchResult(searchUseCase.search(keyword: "char"), expected: [4, 5, 6])
        assertSearchResult(searchUseCase.search(keyword: "TesT"), expected: [3, 5, 7, 9])
    }
    
    private func assertSearchResult(_ search: Single<[SearchedPokemon]>, expected: [PokemonId]) {
        let ids = try! search.toBlocking().single().map { $0.id }.sorted(by: <)
        
        XCTAssertEqual(ids, expected)
    }
}

class TestNameRepository: PokemonNameRepository {
    var designatedNames: [PokemonName]?
    
    func clear() {
        designatedNames = []
    }
    
    func update() -> Completable {
        return .empty()
    }
    
    func allNames() -> Single<[PokemonName]> {
        return .just(designatedNames ?? [])
    }
    
    func names(id: PokemonId) -> Single<[String]> {
        return .just([])
    }
}
