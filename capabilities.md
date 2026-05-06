# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- Photo Library access required (scan, display, delete photos)
- No iCloud sync needed (100% offline, local-only)
- No push notifications needed
- No HealthKit needed
- No location services needed
- No camera access needed (reads existing photos only)
- In-App Purchase required (one-time Pro upgrade)
- No background modes needed
- No Apple Watch companion needed
- No Siri integration needed

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| Photo Library Access | ✅ Configured | Info.plist NSPhotoLibraryUsageDescription + INFOPLIST_KEY in project.pbxproj |
| In-App Purchase | ✅ Configured | StoreKit 2 framework (no entitlement needed) |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| App Store Connect IAP | ⏳ Pending | 1. Create app in App Store Connect 2. Create Non-Consumable IAP: com.zzoutuo.PhotoSlim.pro at $9.99 3. Configure StoreKit Configuration File for testing |

## No Configuration Needed

- Push Notifications: Not required
- iCloud / CloudKit: Not required (100% offline)
- HealthKit: Not required
- Camera: Not required (reads existing photos only)
- Location Services: Not required
- Apple Watch: Not required
- Siri: Not required
- Background Modes: Not required
- Sign in with Apple: Not required

## Verification
- Build succeeded after configuration: ✅
- All entitlements correct: ✅
