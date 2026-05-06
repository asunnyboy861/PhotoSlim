# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | PhotoSlim |
| **Git URL** | git@github.com:asunnyboy861/PhotoSlim.git |
| **Repo URL** | https://github.com/asunnyboy861/PhotoSlim |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/PhotoSlim/ | ✅ Active |
| Support | https://asunnyboy861.github.io/PhotoSlim/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/PhotoSlim/privacy.html | ✅ Active |

**Note**: Terms of Use not required for Non-Consumable IAP (one-time purchase) apps. Only Support + Privacy Policy needed.

## Repository Structure

```
PhotoSlim/
├── PhotoSlim/                       # iOS App Source Code
│   ├── PhotoSlim.xcodeproj/         # Xcode Project
│   ├── PhotoSlim/                   # Swift Source Files
│   │   ├── Models/
│   │   ├── Services/
│   │   ├── ViewModels/
│   │   ├── Views/
│   │   │   ├── Home/
│   │   │   ├── Scan/
│   │   │   ├── Clean/
│   │   │   ├── Report/
│   │   │   ├── Settings/
│   │   │   └── Onboarding/
│   │   ├── Utilities/
│   │   └── PhotoSlimApp.swift
│   └── PhotoSlimTests/
├── docs/                            # Policy Pages (GitHub Pages source)
│   ├── index.html                   # Landing Page
│   ├── support.html                 # Support Page
│   └── privacy.html              # Privacy Policy
├── .github/workflows/
│   └── deploy.yml                   # GitHub Pages deployment
├── us.md                            # English Development Guide
├── keytext.md                       # App Store Metadata
├── capabilities.md                  # Capabilities Configuration
├── icon.md                          # App Icon Details
├── price.md                         # Pricing Configuration
└── nowgit.md                        # This File
```
