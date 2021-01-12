# Pokemon

## 적용한 기술
RxSwift, MVI(ReactorKit), Clean architecture, TDD

## 구현 상세
- Pokemon의 이름 정보는 앱 시작시와 foreground 진입시마다 갱신되며, user defaults에 저장합니다.
- Pokemon 상세 정보는 조회시 서버로부터 갱신되며, 메모리에 캐시됩니다.
- 위치 정보는 앱 시작시와 foreground 진입시, 그리고 상세 정보 조회시 갱신되며, 메모리에 캐시됩니다.

## 코드 구조
- Core part(플랫폼 독립적인 부분, 비즈니스 로직)와 detail part(UI, networking)을 서로 다른 target에 나누는 것이 좋지만, 편의상 폴더로만 구분하도록 구현했습니다.

### Domain
- Domain/Entities: 도메인에서 다루는 오브젝트 모델
- Domain/UseCases: 비즈니스 로직
- Domain/RepositoryInterfaces: UseCase에서 사용할 데이터 저장소

### Data
- Data/RepositoryImplements: domain의 repository의 구현체
- Data/DataSource/Interfaces: repoistory에서 참조하는 data source의 인터페이스
- Data/DataSource/Implements: data source 구현체
- Data/DataSource/Implements/Common: 네트워크 통신을 위한 프로토콜과 Alamofire를 사용한 구현체, Decoding을 위한 유틸리티 클래스

### ViewModels
- Presenter layer, 각 화면을 위한 ViewModel(Reactor class)

### UI
- ViewControllers, Storyboards

### Main
- MainContainer: Data source, Repository들을 가지고 있으며, Use case를 생성
- ViewProvider: 앱 상의 모든 view controller를 생성. 적합한 view model을 생성하여 주입

## 테스트 코드
### PokemonUseCaseTests
- 검색 관련 로직을 검증합니다.

### PokemonRemoteDataSourceTests
- API 응답으로 내려온 json에 따른 decoding 결과를 검증합니다.

### PokemonViewModelTests
- 각 뷰 모델에서 action에 따른 state 결과를 검증합니다.
