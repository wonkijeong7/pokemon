//
//  PokemonLocationViewController.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/12.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import MapKit

protocol PokemonLocationViewProvider {
    func locationViewController(id: PokemonId) -> UIViewController
}

class PokemonLocationViewController: UIViewController, StoryboardView {
    typealias Reactor = PokemonLocationViewReactor
    
    var disposeBag = DisposeBag()
    
    @IBOutlet private weak var mapView: MKMapView!
    
    func bind(reactor: PokemonLocationViewReactor) {
        bindViews(reactor: reactor)
        bindEvents(reactor: reactor)
    }
    
    private func bindViews(reactor: PokemonLocationViewReactor) {
        reactor.state.map { $0.name }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak self] in
                self?.title = $0
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.knownLocations }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] in
                self?.setLocations($0)

            })
            .disposed(by: disposeBag)
    }
    
    private func bindEvents(reactor: PokemonLocationViewReactor) {
        reactor.state.map { $0.event }
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak self] in
                guard let event = $0 else { return }
                
                switch event {
                case .close:
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension PokemonLocationViewController {
    private struct Constants {
        static let paddingValue = CGFloat(500)
        static let edagePadding = UIEdgeInsets(top: paddingValue,
                                               left: paddingValue,
                                               bottom: paddingValue,
                                               right: paddingValue)
    }
    
    // Annotation을 모두 포함하도록 mapView의 줌을 설정하는 방법은
    // https://gist.github.com/andrewgleave/915374 를 참고함.
    
    private func setLocations(_ locations: [Location]) {
        var rect = MKMapRect.null
        
        locations.forEach {
            let annotation = MKPointAnnotation(location: $0)
            
            let point = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
            
            if rect.isNull {
                rect = pointRect
            } else {
                rect = rect.union(pointRect)
            }
            
            self.mapView.addAnnotation(annotation)
        }
        
        self.mapView.setVisibleMapRect(rect, edgePadding: Constants.edagePadding, animated: true)
    }
}

private extension MKPointAnnotation {
    convenience init(location: Location) {
        self.init()
        
        coordinate = CLLocationCoordinate2D(latitude: location.latitude,
                                            longitude: location.longitude)
    }
}
