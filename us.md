# PhotoSlim - iOS Development Guide

## Executive Summary

PhotoSlim is an offline AI photo cleaner and organizer for iPhone and iPad. It uses on-device AI (Apple Vision framework) to detect duplicate, blurry, and unnecessary photos, then helps users clean them up in seconds. The app differentiates itself through three core pillars: 100% offline processing (zero data collection), one-time purchase pricing ($9.99 vs competitors' $364/year subscriptions), and a full-featured suite (duplicates + blur + screenshots + face groups + storage dashboard).

**Target Audience**: US market, privacy-conscious iPhone users with 5,000+ photos, photography enthusiasts, and anyone running out of storage.

**Key Differentiators**:
- 100% on-device AI processing - photos never leave the device
- One-time $9.99 purchase - no subscription
- Full feature suite in one app - duplicates, blur, screenshots, face groups
- Stable with 100,000+ photo libraries
- Zero third-party dependencies - 100% Apple native frameworks

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| Apple Photos (Built-in) | Free, system-integrated, exact duplicate detection | Only detects exact duplicates; no blur detection; no screenshot classification | Similar photo detection + blur recognition + smart classification |
| CleanMyPhone (Gemini) | Popular brand, comprehensive features | $7/week subscription ($364/year); crashes on 60K+ photos; high false positive rate | One-time $9.99; stable with 100K+ photos; higher accuracy AI |
| Snapsift | 100% on-device, fast 60s scan, sharp photo selection | $19.99/year subscription; limited to duplicate detection only | One-time purchase; full feature suite including blur + screenshots + face groups |
| Clever Cleaner | Completely free, no ads, AI duplicate detection | No blur detection; no screenshot cleanup; no face groups; iPad not optimized | Full feature suite; optimized iPad layout; face group organization |
| Cisdem Duplicate Finder | Cross-platform, adjustable similarity threshold | Requires desktop; not a standalone iOS app | Native iOS app; works entirely on-device; no computer needed |
| Google Photos | Cloud backup, AI search, sharing | Uploads photos to cloud; uses data for AI training; privacy concerns | 100% offline; zero data collection; no cloud dependency |

## Apple Design Guidelines Compliance

- **Clarity**: Clean, uncluttered interface with clear visual hierarchy. Storage dashboard provides instant insight. Category cards use distinct icons and colors.
- **Consistency**: Standard TabView navigation (Home, Clean, Report, Settings). Native SwiftUI components throughout. SF Symbols for all icons.
- **Deference**: Content-first design. Photos are the hero - large thumbnails, minimal chrome. Progress indicators don't obstruct content.
- **Depth**: Layered card design with subtle shadows. Matched geometry effects for photo transitions. Ring chart for storage visualization.
- **Accessibility**: VoiceOver labels on all images. Dynamic Type support. WCAG 2.1 AA color contrast. Reduce motion support.
- **Liquid Glass (iOS 26)**: Design prepared for translucent material adoption. Card-based layout compatible with new depth system.

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), UIKit (PHImageManager callbacks)
- **AI/ML**: Vision Framework (VNFeaturePrintObservation, VNDetectFaceRectanglesRequest), Core Image (Laplacian variance)
- **Data**: SwiftData (iOS 17+) for local persistence
- **Hashing**: CryptoKit (SHA-256 for exact duplicate detection)
- **Photos**: PhotoKit (PHAsset, PHImageManager, PHAssetChangeRequest)
- **Payments**: StoreKit 2 (Non-consumable IAP)
- **Concurrency**: Swift Concurrency (async/await, TaskGroup)
- **Image Processing**: ImageIO + Core Image (EXIF, thumbnails, blur analysis)
- **Third-party Dependencies**: None - 100% Apple native frameworks

## Module Structure

```
PhotoSlim/
├── PhotoSlimApp.swift
├── Models/
│   ├── PhotoRecord.swift
│   ├── ScanSession.swift
│   ├── UserPreferences.swift
│   ├── DuplicateGroup.swift
│   ├── BlurResult.swift
│   └── PhotoCategory.swift
├── Services/
│   ├── PhotoLibraryService.swift
│   ├── DuplicateDetector.swift
│   ├── BlurDetector.swift
│   ├── SmartClassifier.swift
│   ├── FaceDetector.swift
│   ├── ScanOrchestrator.swift
│   └── StoreManager.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── ScanViewModel.swift
│   ├── CleanViewModel.swift
│   ├── ReportViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── StorageRingView.swift
│   │   └── CategoryCardView.swift
│   ├── Scan/
│   │   ├── ScanView.swift
│   │   └── ScanResultView.swift
│   ├── Clean/
│   │   ├── CleanView.swift
│   │   ├── DuplicateDetailView.swift
│   │   ├── BlurDetailView.swift
│   │   └── ScreenshotDetailView.swift
│   ├── Report/
│   │   ├── ReportView.swift
│   │   └── PrivacyBadgeView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── ContactSupportView.swift
│   └── Onboarding/
│       └── OnboardingView.swift
└── Utilities/
    ├── AnimatableNumber.swift
    └── ImageLoader.swift
```

## Implementation Flow

1. Create SwiftData models (PhotoRecord, ScanSession, UserPreferences)
2. Implement PhotoLibraryService (PhotoKit wrapper for fetching and deleting assets)
3. Build DuplicateDetector engine (SHA-256 exact match + Vision FeaturePrint similar match)
4. Build BlurDetector engine (Laplacian variance analysis via Core Image)
5. Build SmartClassifier (screenshot detection via image dimensions + pixel analysis)
6. Build FaceDetector (VNDetectFaceRectanglesRequest for face grouping)
7. Implement ScanOrchestrator (coordinates all detectors with progress tracking)
8. Build HomeView with storage dashboard and category cards
9. Build ScanView with progress bar and real-time discovery counts
10. Build CleanView with duplicate/blur/screenshot detail views
11. Build ReportView with storage savings and cleanup history
12. Build SettingsView with scan thresholds and privacy info
13. Implement StoreManager (StoreKit 2 non-consumable IAP)
14. Build OnboardingView (3-page welcome flow)
15. Build ContactSupportView (feedback submission)
16. Integrate all views in TabView navigation
17. Test on iPhone and iPad simulators

## UI/UX Design Specifications

- **Color Scheme**: 
  - Primary: #007AFF (System Blue)
  - Success: #34C759 (Green) for clean/safe actions
  - Danger: #FF3B30 (Red) for delete actions
  - Warning: #FF9500 (Orange) for blur indicators
  - Background: System background (adaptive light/dark)
  - Card Background: Secondary system grouped background

- **Typography**: 
  - Large Title: 34pt Bold (dashboard numbers)
  - Title 2: 22pt Semibold (section headers)
  - Title 3: 20pt Semibold (card titles)
  - Body: 17pt Regular (descriptions)
  - Caption: 12pt Regular (metadata)

- **Layout**:
  - TabView with 4 tabs: Home, Clean, Report, Settings
  - Cards with 16pt corner radius and subtle shadows
  - 16pt horizontal padding, 12pt vertical spacing
  - iPad: max width 720pt for content, centered
  - Grid: 3-column for category cards, 2-column for photo comparison

- **Animations**:
  - Scan progress: ring chart fill animation (0.8s)
  - Photo delete: scale + opacity transition (0.25s)
  - Cleanup complete: number counter animation (1.0s)
  - Card expand: matched geometry effect (0.35s)
  - Tab switch: opacity transition (0.2s)

## Code Generation Rules

- One feature per module, high cohesion, low coupling
- MVVM pattern: View + ViewModel for each feature
- All SwiftData model attributes must be optional or have default values
- All SwiftData relationships must have inverse relationships
- Use @Observable macro for ViewModels (iOS 17+)
- Use async/await for all service operations
- No third-party dependencies - Apple native frameworks only
- No code comments unless explicitly requested
- iPad layout: always add .frame(maxWidth: 720).frame(maxWidth: .infinity) for ScrollView content
- Never use .tabViewStyle(.sidebarAdaptable)

## Build & Deployment Checklist

1. Verify Bundle ID: com.zzoutuo.PhotoSlim
2. Verify Deployment Target: iOS 17.0
3. Add Photo Library usage description to Info.plist
4. Configure App Icon in Asset Catalog
5. Enable StoreKit 2 for IAP
6. Create StoreKit Configuration file for testing
7. Test on iPhone XS Max simulator
8. Test on iPad Pro 13-inch (M4) simulator
9. Verify no memory leaks with Instruments
10. Test with large photo libraries (10K+)
11. Verify dark mode support
12. Verify VoiceOver accessibility
13. Push to GitHub repository
14. Deploy policy pages to GitHub Pages
15. Submit to App Store Connect
