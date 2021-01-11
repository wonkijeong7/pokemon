//
//  PokemonDescriptionViewController.swift
//  Pokemon
//
//  Created by 정원기 on 2021/01/12.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

protocol PokemonDescriptionViewProvider {
    func descriptionViewController(id: PokemonId, openLocationObserver: AnyObserver<PokemonId>) -> UIViewController
}

class PokemonDescriptionViewController: UIViewController, StoryboardView {
    typealias Reactor = PokemonDescriptionViewReactor

    var disposeBag =  DisposeBag()
    
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet private weak var representativeNameLabel: UILabel!
    @IBOutlet private weak var thumbnailView: UIImageView!
    @IBOutlet private weak var otherNamesContainerView: UIView!
    @IBOutlet private weak var otherNamesLabel: UILabel!
    @IBOutlet private weak var heightLabel: UILabel!
    @IBOutlet private weak var weightLabel: UILabel!
    
    @IBOutlet private weak var showLocationButton: UIControl!
    @IBOutlet private weak var closeButton: UIButton!
    
    private struct Constants {
        static let emptyString = "-"
    }
    
    func bind(reactor: PokemonDescriptionViewReactor) {
        bindViews(reactor: reactor)
        bindActions(reactor: reactor)
        bindEvents(reactor: reactor)
    }
    
    private func bindViews(reactor: PokemonDescriptionViewReactor) {
        reactor.state.map { !$0.isLoading }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .do(onNext: { [loadingView] in
                if !$0 {
                    loadingView?.startAnimating()
                } else {
                    loadingView?.stopAnimating()
                }
            })
            .drive(loadingView.rx.isHidden)
            .disposed(by: disposeBag)
            
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: true)
            .drive(contentView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.description?.representativeName }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: Constants.emptyString)
            .drive(representativeNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map {
                guard let thumbnail = $0.thumbnail else { return nil }
                
                return UIImage(data: thumbnail)
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(thumbnailView.rx.image)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.description?.otherNames.isEmpty != false }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: true)
            .drive(otherNamesLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.description?.otherNames.joined(separator: ", ") }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: Constants.emptyString)
            .drive(otherNamesLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map {
                guard let description = $0.description else { return Constants.emptyString }

                return "\(Int(description.height))"
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: Constants.emptyString)
            .drive(heightLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map {
                guard let description = $0.description else { return Constants.emptyString }
                
                return "\(Int(description.weight))"
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: Constants.emptyString)
            .drive(weightLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { !$0.hasKnownLocations }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: true)
            .drive(showLocationButton.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func bindActions(reactor: PokemonDescriptionViewReactor) {
        showLocationButton.rx.controlEvent(.touchUpInside)
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                reactor.action.onNext(.showLocation)
            })
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                reactor.action.onNext(.close)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindEvents(reactor: PokemonDescriptionViewReactor) {
        reactor.state.map { $0.event }
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [weak self] in
                guard let event = $0 else { return }
                
                switch event {
                case .showErrorAlert:
                    self?.showErrorAlert()
                case .close:
                    self?.dismiss(animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "정보를 가져오는 데 실패했습니다.", message: "다시 시도해 주세요.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "재시도", style: .default, handler: { [reactor] _ in
            reactor?.action.onNext(.initialize)
        }))
        
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: { [reactor] _ in
            reactor?.action.onNext(.close)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
