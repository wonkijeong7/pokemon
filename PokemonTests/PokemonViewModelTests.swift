//
//  PokemonViewModelTests.swift
//  PokemonTests
//
//  Created by 정원기 on 2021/01/12.
//

import XCTest
@testable import Pokemon

import RxSwift
import RxBlocking
import ReactorKit

class PokemonSearchReactorTests: XCTestCase {
    var testUseCase = TestSearchUseCase()
    
    override func setUp() {
        super.setUp()
        
        testUseCase.clear()
    }
    
    func test_search() throws {
        let expectedSearchResult = [
            SearchedPokemon(id: 3, matchedName: "test"),
            SearchedPokemon(id: 5, matchedName: "test2")
        ]
        
        testUseCase.testSearchResult = expectedSearchResult

        let reactor = PokemonSearchViewReactor(searchUseCase: testUseCase)
        
        reactor.action.onNext(.search(keyword: "test"))
        
        XCTAssertEqual(reactor.currentState.searchResult, expectedSearchResult)
        
        // showDescription
        
        reactor.action.onNext(.showDescription(index: 0))
        
        switch reactor.currentState.event {
        case .showDescription(let id):
            XCTAssertEqual(id, 3)
        default:
            XCTFail()
        }
    }
    
    func test_search_error() throws {
        let expectedError = TestError.test
        
        testUseCase.testError = expectedError
        
        let reactor = PokemonSearchViewReactor(searchUseCase: testUseCase)
        
        reactor.action.onNext(.search(keyword: "test"))
        
        switch reactor.currentState.event {
        case .showSearchError(let keyword):
            XCTAssertEqual(keyword, "test")
        default:
            XCTFail()
        }
    }
}

class PokemonDescriptionReactorTests: XCTestCase {
    let descriptionUseCase = TestDescriptionUseCase()
    let locationUseCase = TestLocationUseCase()
    var testShowLocationPublisher = BehaviorSubject<PokemonId>(value: 0)
    var disposeBag = DisposeBag()
    
    let testPokemonId: PokemonId = 5
    lazy var testDescription = PokemonDescription(id: testPokemonId,
                                                  representativeName: "testName",
                                                  otherNames: ["other1", "other2"],
                                                  height: 5,
                                                  weight: 40,
                                                  hasThumbnail: true)
    let testThumbnailData = "thumbnailData".data(using: .utf8)
    let testLocations = [Location(latitude: 1, longitude: 2),
                         Location(latitude: 3, longitude: 4)]
    
    override func setUp() {
        super.setUp()
        
        descriptionUseCase.clear()
        locationUseCase.clear()
        disposeBag = DisposeBag()
        testShowLocationPublisher = BehaviorSubject<PokemonId>(value: 0)
    }
    
    func test_initialize() throws {
        descriptionUseCase.testDescription = testDescription
        descriptionUseCase.testThumbnail = testThumbnailData
        locationUseCase.testKnownLocations = testLocations
        
        let reactor = PokemonDescriptionViewReactor(pokemonId: testPokemonId,
                                                    showLocationObserver: testShowLocationPublisher.asObserver(),
                                                    descriptionUseCase: descriptionUseCase,
                                                    locationUseCase: locationUseCase)

        XCTAssertEqual(reactor.currentState.description?.id, testDescription.id)
        XCTAssertEqual(reactor.currentState.description?.representativeName, testDescription.representativeName)
        XCTAssertEqual(reactor.currentState.description?.otherNames, testDescription.otherNames)
        XCTAssertEqual(reactor.currentState.description?.height, testDescription.height)
        XCTAssertEqual(reactor.currentState.description?.weight, testDescription.weight)
        XCTAssertEqual(reactor.currentState.description?.hasThumbnail, testDescription.hasThumbnail)
        
        XCTAssertEqual(reactor.currentState.thumbnail, testThumbnailData)
        XCTAssertEqual(reactor.currentState.hasKnownLocations, true)
        XCTAssertEqual(reactor.currentState.isLoading, false)
        XCTAssertNil(reactor.currentState.event)
    }
    
    func test_initialize_description_error() throws {
        descriptionUseCase.testDescriptionError = TestError.test
        descriptionUseCase.testThumbnail = testThumbnailData
        locationUseCase.testKnownLocations = testLocations
        
        let reactor = PokemonDescriptionViewReactor(pokemonId: testPokemonId,
                                                    showLocationObserver: testShowLocationPublisher.asObserver(),
                                                    descriptionUseCase: descriptionUseCase,
                                                    locationUseCase: locationUseCase)

        XCTAssertNil(reactor.currentState.description)
        
        XCTAssertEqual(reactor.currentState.event, .showErrorAlert)
        XCTAssertEqual(reactor.currentState.isLoading, true)
    }
    
    func test_initialize_thumbnail_error() throws {
        descriptionUseCase.testDescription = testDescription
        descriptionUseCase.testThumbnailError = TestError.test
        locationUseCase.testKnownLocations = testLocations
        
        let reactor = PokemonDescriptionViewReactor(pokemonId: testPokemonId,
                                                    showLocationObserver: testShowLocationPublisher.asObserver(),
                                                    descriptionUseCase: descriptionUseCase,
                                                    locationUseCase: locationUseCase)

        XCTAssertEqual(reactor.currentState.description?.id, testDescription.id)
        XCTAssertEqual(reactor.currentState.description?.representativeName, testDescription.representativeName)
        XCTAssertEqual(reactor.currentState.description?.otherNames, testDescription.otherNames)
        XCTAssertEqual(reactor.currentState.description?.height, testDescription.height)
        XCTAssertEqual(reactor.currentState.description?.weight, testDescription.weight)
        XCTAssertEqual(reactor.currentState.description?.hasThumbnail, testDescription.hasThumbnail)
        XCTAssertEqual(reactor.currentState.hasKnownLocations, true)
        
        XCTAssertNil(reactor.currentState.thumbnail)
        XCTAssertNil(reactor.currentState.event)
        XCTAssertEqual(reactor.currentState.isLoading, false)
    }
    
    func test_initialize_location_error() throws {
        descriptionUseCase.testDescription = testDescription
        descriptionUseCase.testThumbnail = testThumbnailData
        locationUseCase.testError = TestError.test
        
        let reactor = PokemonDescriptionViewReactor(pokemonId: testPokemonId,
                                                    showLocationObserver: testShowLocationPublisher.asObserver(),
                                                    descriptionUseCase: descriptionUseCase,
                                                    locationUseCase: locationUseCase)

        XCTAssertEqual(reactor.currentState.description?.id, testDescription.id)
        XCTAssertEqual(reactor.currentState.description?.representativeName, testDescription.representativeName)
        XCTAssertEqual(reactor.currentState.description?.otherNames, testDescription.otherNames)
        XCTAssertEqual(reactor.currentState.description?.height, testDescription.height)
        XCTAssertEqual(reactor.currentState.description?.weight, testDescription.weight)
        XCTAssertEqual(reactor.currentState.description?.hasThumbnail, testDescription.hasThumbnail)
        XCTAssertEqual(reactor.currentState.thumbnail, testThumbnailData)
        
        XCTAssertEqual(reactor.currentState.hasKnownLocations, false)
        
        XCTAssertNil(reactor.currentState.event)
        XCTAssertEqual(reactor.currentState.isLoading, false)
    }
    
    func test_show_location() throws {
        descriptionUseCase.testDescription = testDescription
        descriptionUseCase.testThumbnail = testThumbnailData
        locationUseCase.testKnownLocations = testLocations
        
        let reactor = PokemonDescriptionViewReactor(pokemonId: testPokemonId,
                                                    showLocationObserver: testShowLocationPublisher.asObserver(),
                                                    descriptionUseCase: descriptionUseCase,
                                                    locationUseCase: locationUseCase)
        
        reactor.action.onNext(.showLocation)
        
        XCTAssertEqual(reactor.currentState.event, .close)
        XCTAssertEqual(try testShowLocationPublisher.value(), testPokemonId)
    }
}

class PokemonLocationTests: XCTestCase {
    let descriptionUseCase = TestDescriptionUseCase()
    let locationUseCase = TestLocationUseCase()
    let testPokemonId: PokemonId = 5
    let testName = "testName"
    let testLocations = [Location(latitude: 1, longitude: 2),
                         Location(latitude: 3, longitude: 4)]
    
    override func setUp() {
        super.setUp()
        
        descriptionUseCase.clear()
        locationUseCase.clear()
    }
    
    func test_initialize() throws {
        descriptionUseCase.testName = testName
        locationUseCase.testKnownLocations = testLocations
        
        let reactor = PokemonLocationViewReactor(pokemonId: testPokemonId,
                                                 descriptionUseCase: descriptionUseCase,
                                                 locationUseCase: locationUseCase)
        
        XCTAssertEqual(reactor.currentState.name, testName)
        XCTAssertEqual(reactor.currentState.knownLocations, testLocations)
        XCTAssertNil(reactor.currentState.event)
    }
    
    func test_initialize_name_error() throws {
        descriptionUseCase.testNameError = TestError.test
        locationUseCase.testKnownLocations = testLocations
        
        let reactor = PokemonLocationViewReactor(pokemonId: testPokemonId,
                                                 descriptionUseCase: descriptionUseCase,
                                                 locationUseCase: locationUseCase)
        
        XCTAssertEqual(reactor.currentState.name, nil)
        XCTAssertEqual(reactor.currentState.knownLocations, testLocations)
        XCTAssertNil(reactor.currentState.event)
    }
    
    func test_initialize_location_error() throws {
        descriptionUseCase.testName = testName
        locationUseCase.testError = TestError.test
        
        let reactor = PokemonLocationViewReactor(pokemonId: testPokemonId,
                                                 descriptionUseCase: descriptionUseCase,
                                                 locationUseCase: locationUseCase)
        
        XCTAssertEqual(reactor.currentState.name, testName)
        XCTAssertEqual(reactor.currentState.knownLocations, [])
        XCTAssertEqual(reactor.currentState.event, .showError)
    }
}

class TestSearchUseCase: PokemonSearchUseCase {
    var testSearchResult: [SearchedPokemon]?
    var testError: Error?
    
    func clear() {
        testSearchResult = nil
        testError = nil
    }
    
    func search(keyword: String) -> Single<[SearchedPokemon]> {
        if let testResult = testSearchResult {
            return .just(testResult)
        }
        
        if let testError = testError {
            return .error(testError)
        }
        
        return .error(TestError.empty)
    }
}

class TestDescriptionUseCase: PokemonDescriptionUseCase {
    var testName: String?
    var testNameError: Error?
    
    var testDescription: PokemonDescription?
    var testDescriptionError: Error?
    
    var testThumbnail: Data?
    var testThumbnailError: Error?
    
    func clear() {
        testName = nil
        testNameError = nil
        testDescription = nil
        testDescriptionError = nil
    }
    
    func updateMetadata() -> Completable {
        return .empty()
    }
    
    func name(id: PokemonId) -> Single<String> {
        if let testName = testName {
            return .just(testName)
        }
        
        if let error = testNameError {
            return .error(error)
        }
        
        return .error(TestError.empty)
    }
    
    func description(id: PokemonId) -> Single<PokemonDescription> {
        if let testDescription = testDescription {
            return .just(testDescription)
        }
        
        if let error = testDescriptionError {
            return .error(error)
        }
        
        return .error(TestError.empty)
    }
    
    func thumbnail(id: PokemonId) -> Maybe<Data> {
        if let testThumbnail = testThumbnail {
            return .just(testThumbnail)
        }
        
        if let error = testThumbnailError {
            return .error(error)
        }
        
        return .empty()
    }
}

class TestLocationUseCase: PokemonLocationUseCase {
    var testKnownLocations: [Location]?
    var testError: Error?
    
    func clear() {
        testKnownLocations = nil
        testError = nil
    }
    
    func updateKnownLocations() -> Completable {
        return .empty()
    }
    
    func knownLocations(id: PokemonId) -> Single<[Location]> {
        if let knownLocations = testKnownLocations {
            return .just(knownLocations)
        }
        
        if let error = testError {
            return .error(error)
        }
        
        return .just([])
    }
}

enum TestError: Error {
    case test
    case empty
}
