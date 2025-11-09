# CurtainCall - 공연 다이어리

<br/>

## 개발기간
기간: 2025.09.15 ~ 진행 중
> 최신 버전 : v2.3.0

<br/>

## 프로젝트 개요
**CurtainCall**은 KOPIS(공연예술통합전산망) API를 활용하여 뮤지컬과 연극 공연 정보를 제공하는 iOS 앱입니다.  
공연 일정 조회부터 찜하기, 관람 기록 관리까지 공연 팬들을 위한 올인원 서비스를 제공합니다.

<br/>

## 앱 개발 환경
- **최소 버전**: iOS 17.0
- **디바이스**: iPhone 전용
- **화면 방향**: 세로 모드 (Portrait)
- **UI 모드**: 라이트 모드만 지원
- **Xcode**: 16.0+

<br/>

## 핵심 기능

### 1. 공연 검색
- 지역(시도)별 뮤지컬/연극 일정 검색
- 실시간 공연 정보 업데이트

### 2. 상세 정보
- 공연 상세 정보 조회
- 공연장 정보 및 좌석 배치도
- 캐스팅 정보
- 예매 링크 제공 (인터파크, 예스24 등)

### 3. 찜하기
- 관심 공연 저장
- 찜한 목록 조회 및 관리
- Realm 기반 로컬 데이터 저장

### 4. 관람 기록
- 관람한 공연 기록 추가
- 평점 및 리뷰 작성
- 관람 날짜, 동반자, 좌석 정보 저장

### 5. 통계 & 순위
- 장르별 예매 순위
- 지역별 공연 통계
- 개인 관람 통계 (장르별, 기간별)

## 아키텍처

### Clean Architecture + MVVM (Input/Output)

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                      │
│  ┌─────────────┐               ┌───────────────────────┐    │
│  │    View     │────────────-──│  ViewModel (I/O)      │    │
│  │  (UIKit)    │  Input/       │  - transform()        │    │
│  │             │  Output       │  - ViewModelType      │    │
│  └─────────────┘               └───────────────────────┘    │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│                      Domain Layer                           │
│  ┌─────────────────┐          ┌──────────────────────┐      │
│  │   Use Cases     │────────--│  Domain Models       │      │
│  │  - Business     │          │  - Performance       │      │
│  │    Logic        │          │  - ViewingRecord     │      │
│  └─────────────────┘          └──────────────────────┘      │
│           │                                                 │
│           └─────────────┐                                   │
│                         ▼                                   │
│         ┌────────────────────────────┐                      │
│         │  Repository Protocols      │                      │
│         │  (Interface)               │                      │
│         └────────────────────────────┘                      │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────┴────────────────────────────────────┐
│                       Data Layer                            │
│  ┌──────────────────┐          ┌───────────────────┐        │
│  │  API Repository  │          │ Local Repository  │        │
│  │  - KOPIS API     │          │ - Realm DB        │        │
│  │  - Alamofire     │          │ - Cache           │        │
│  └──────────────────┘          └───────────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

### ViewModelType 프로토콜

```swift
protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
```

- **Input**: View에서 전달되는 이벤트 (버튼 탭, 텍스트 입력 등)
- **Output**: ViewModel에서 View로 전달되는 데이터 스트림
- **명확한 데이터 흐름**: 단방향 데이터 플로우로 예측 가능한 상태 관리

<br/>

## 기술 스택

### Architecture & Pattern
- **Clean Architecture**: 계층 분리를 통한 유지보수성 향상
- **MVVM (Input/Output)**: ViewModelType 프로토콜 기반
- **Repository Pattern**: 데이터 소스 추상화
- **Dependency Injection**: DI Container

### UI Framework
- **UIKit**: 코드 기반 UI 구현
- **SnapKit**: Auto Layout 라이브러리
- **DiffableDataSource**: 효율적인 컬렉션뷰 업데이트

### Reactive Programming
- **RxSwift**: 반응형 프로그래밍
- **RxCocoa**: UIKit 바인딩

### Network
- **Alamofire**: HTTP 네트워킹
- **Parsely**: XML 파싱 (개인 라이브러리)

### Database
- **Realm**: 로컬 데이터베이스
  - 찜한 공연 저장
  - 관람 기록 관리
  - 최근 검색어 저장

### Image
- **Kingfisher**: 이미지 로딩 및 캐싱

### Utilities
- **OSLog**: 구조화된 로깅
- **Firebase**: Push Notification

## SOLID 원칙 적용

### 1. Single Responsibility Principle (단일 책임 원칙)
```swift
class HomeViewController {
    // UI만 담당
}

class HomeViewModel {
    // 비즈니스 로직만 담당
}

class PerformanceRepository {
    // 데이터 접근만 담당
}
```

### 2. Open/Closed Principle (개방/폐쇄 원칙)
```swift
protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

class BaseViewModel: ViewModelType {
    // 기본 구현
}

class HomeViewModel: BaseViewModel {
    // 확장: 새로운 기능 추가
}
```

### 3. Liskov Substitution Principle (리스코프 치환 원칙)
```swift
let viewModel: ViewModelType = HomeViewModel()
let output = viewModel.transform(input: input)
```

### 4. Interface Segregation Principle (인터페이스 분리 원칙)
```swift
protocol FavoriteRepositoryProtocol {
    func getFavorites() -> [FavoriteDTO]
    func addFavorite(_ favorite: FavoriteDTO) throws
}

protocol SearchRepositoryProtocol {
    func searchPerformances(keyword: String) -> Observable<[Performance]>
}
```

### 5. Dependency Inversion Principle (의존성 역전 원칙)
```swift
class HomeViewModel {
    private let performanceRepository: PerformanceRepositoryProtocol
    
    init(performanceRepository: PerformanceRepositoryProtocol) {
        self.performanceRepository = performanceRepository
    }
}
```

<br/>

## API 설정

### 1. KOPIS API 키 발급
1. [KOPIS 공연예술통합전산망](http://www.kopis.or.kr) 접속
2. 회원가입 및 로그인
3. `마이페이지` > `인증키 발급` 에서 API 키 발급

### 2. Xcode 설정
```bash
# Config.xcconfig 파일 생성
KOPIS_API_KEY = your_api_key_here
KOPIS_BASE_URL = http:/$()/www.kopis.or.kr/openApi/restful
```

### 3. Info.plist 설정
```xml
<key>KOPIS_API_KEY</key>
<string>$(KOPIS_API_KEY)</string>
<key>KOPIS_BASE_URL</key>
<string>$(KOPIS_BASE_URL)</string>
```

### 구조
```swift
// MARK: - Properties
private let disposeBag = DisposeBag()

// MARK: - UI Components
private let titleLabel: UILabel = { }()

// MARK: - Lifecycle
override func viewDidLoad() { }

// MARK: - Public Methods
func configure() { }

// MARK: - Private Methods
private func setupUI() { }

// MARK: - Actions
@objc private func didTapButton() { }
```

## 라이선스

MIT_LICENSE

<br/>

## 개발자

**서준일**
- GitHub: [@junil1030](https://github.com/junil1030)
- Email: dccrdseo@naver.com

