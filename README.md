# MindMap

OPML 2.0 규격을 사용하는 크로스 플랫폼(macOS/iOS) 마인드맵 애플리케이션

## 기능

- ✅ OPML 2.0 파일 형식 완벽 지원 (읽기/쓰기/자동 동기화)
- ✅ SwiftUI 기반 인터랙티브 마인드맵 시각화
- ✅ SwiftData를 사용한 데이터 관리
- ✅ macOS 및 iOS 크로스 플랫폼 지원
- ✅ 노드 생성, 편집, 드래그 이동
- ✅ 계층 구조 관리 (부모-자식 관계)
- ✅ 줌, 팬 제스처 지원
- ✅ iCloud CloudKit 자동 동기화
- ✅ 문서 기반 앱 (여러 마인드맵 파일 관리)

## 프로젝트 구조

```
MindMap/
├── project.yml                   # XcodeGen 설정 파일
├── MindMap.xcodeproj/            # 생성된 Xcode 프로젝트
├── MindMap/                      # 공유 소스 코드 (macOS + iOS)
│   ├── App/
│   │   └── MindMapApp.swift     # 앱 진입점
│   ├── Models/
│   │   ├── OPML/                # OPML 2.0 구현
│   │   │   ├── OPMLDocument.swift
│   │   │   ├── OPMLParser.swift
│   │   │   └── OPMLGenerator.swift
│   │   └── Data/                # 데이터 모델
│   │       ├── MindMapNode.swift
│   │       └── MindMapDocument.swift
│   └── Views/                   # UI 컴포넌트
│       ├── ContentView.swift
│       ├── MindMapCanvasView.swift
│       └── NodeView.swift
├── MindMapMac/                  # macOS 전용 리소스
│   ├── Info.plist
│   ├── MindMap.entitlements
│   └── Assets.xcassets/
└── MindMapiOS/                  # iOS 전용 리소스
    ├── Info.plist
    ├── MindMap.entitlements
    └── Assets.xcassets/
```

## 시작하기

### 요구 사항

- macOS 14.0 이상
- Xcode 15.0 이상
- Swift 5.9 이상

### Xcode에서 프로젝트 열기

```bash
open MindMap.xcodeproj
```

### 빌드 및 실행

1. Xcode에서 `MindMap.xcodeproj` 열기
2. 타겟 선택:
   - macOS: `MindMap-macOS`
   - iOS: `MindMap-iOS`
3. ⌘R 로 빌드 및 실행

### 프로젝트 재생성 (XcodeGen 사용)

프로젝트 구조를 변경한 경우 다음 명령으로 재생성:

```bash
xcodegen generate
```

## 주요 기능 사용법

### 1. 마인드맵 노드 추가

- **루트 노드 추가**: 툴바의 "+" 버튼 클릭
- **자식 노드 추가**: 노드 선택 후 "↓" 버튼 클릭

### 2. 노드 편집

- 노드를 더블 클릭하여 텍스트 편집 모드 진입
- Enter 키로 편집 완료

### 3. 노드 이동

- 노드를 드래그하여 원하는 위치로 이동
- 이동 시 자동으로 OPML 문서에 저장

### 4. 뷰 조작

- **캔버스 팬(이동)**: 빈 공간 드래그
- **줌**: 핀치 제스처 (트랙패드에서 두 손가락)
- **줌 인/아웃**: 툴바 버튼
- **뷰 리셋**: 툴바의 리셋 버튼

### 5. OPML 파일 작업

- **새 파일**: ⌘N
- **파일 열기**: ⌘O
- **저장**: ⌘S (자동 저장됨)
- **수동 동기화**: 툴바의 동기화 버튼

### 6. iCloud 동기화

- 앱 실행 시 자동으로 iCloud와 동기화
- 여러 기기에서 동일한 계정으로 로그인하면 자동으로 데이터 동기화
- 인터넷 연결 시 실시간 동기화

## OPML 2.0 스펙 준수

이 앱은 OPML 2.0 표준을 완벽히 지원합니다:

- ✅ 표준 head 요소 (title, dateCreated, dateModified, owner 정보 등)
- ✅ 계층적 outline 구조
- ✅ 커스텀 속성 지원
- ✅ RFC 822 날짜 형식
- ✅ XML 이스케이핑 처리

### 커스텀 속성

마인드맵 특화 정보는 언더스코어 prefix로 OPML에 저장됩니다:

- `_position_x`, `_position_y`: 노드 위치
- `_color`: 노드 색상 (hex)
- `_fontSize`: 폰트 크기
- `_collapsed`: 접힘 상태

## 기술 스택

- **UI Framework**: SwiftUI
- **데이터 관리**: SwiftData
- **파일 포맷**: OPML 2.0 (XML)
- **클라우드 동기화**: CloudKit (예정)
- **의존성 관리**: Swift Package Manager
- **프로젝트 생성**: XcodeGen

## 완료된 기능

- [x] 기본 마인드맵 UI
- [x] OPML 2.0 파서/생성기
- [x] SwiftData 모델
- [x] 노드 생성/편집/드래그
- [x] OPML 파일 자동 동기화
- [x] iCloud CloudKit 동기화
- [x] 문서 기반 앱 구조
- [x] 크로스 플랫폼 지원 (macOS/iOS)

## 향후 개선 계획

- [ ] 노드 색상 커스터마이징 UI
- [ ] 다양한 레이아웃 알고리즘 (트리, 방사형 등)
- [ ] 검색 기능
- [ ] 태그 및 필터링
- [ ] Markdown/PDF 내보내기
- [ ] 실행 취소/다시 실행
- [ ] 노드 스타일 템플릿
- [ ] 키보드 단축키 확장
- [ ] 다른 클라우드 서비스 연동 (Dropbox, Google Drive)

## 개발

### 코드 스타일

- Swift 5.9+ 기능 사용
- SwiftUI 모범 사례 준수
- MVVM 아키텍처 패턴

### 테스트

(테스트 추가 예정)

## 라이선스

(라이선스 정보 추가 예정)

## 기여

기여를 환영합니다! Pull Request를 보내주세요.
