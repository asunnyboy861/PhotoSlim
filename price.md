# Pricing Configuration

## Monetization Model: Free + Non-Consumable IAP

- **Free Tier**: Full scan + limited daily cleaning (5 photos/day)
- **Pro Upgrade**: $9.99 one-time purchase - unlimited everything
- **Subscription**: None
- **Model Type**: Freemium with Non-Consumable IAP

## App Store Connect Pricing

- **Price Tier**: Free (with In-App Purchase)

## In-App Purchase

### Non-Consumable: PhotoSlim Pro

| Field | Value |
|-------|-------|
| **Reference Name** | PhotoSlim Pro |
| **Product ID** | `com.zzoutuo.PhotoSlim.pro` |
| **Type** | Non-Consumable |
| **Price** | $9.99 (Tier 9) |
| **Display Name** | PhotoSlim Pro |
| **Description** | Unlimited photo cleaning and all Pro features |

### Free Tier Limits

| Feature | Free | Pro |
|---------|------|-----|
| Photo Library Scan | ✅ Full scan | ✅ Full scan |
| Duplicate Detection | ✅ View results | ✅ View + delete |
| Blur Detection | ✅ View results | ✅ View + delete |
| Screenshot Cleanup | ✅ View results | ✅ View + delete |
| Daily Delete Limit | 5 photos/day | Unlimited |
| Face Groups | ❌ | ✅ |
| Storage Dashboard | ✅ | ✅ |
| Scan History | ❌ | ✅ |

## Policy Pages Required

- Support Page: ✅
- Privacy Policy: ✅
- Terms of Use: ❌ (Not required for Non-Consumable IAP - only required for subscriptions)

## Note

PhotoSlim uses a one-time purchase model (Non-Consumable IAP), NOT a subscription. This is a key differentiator from competitors like CleanMyPhone ($7/week = $364/year) and Snapsift ($19.99/year). Terms of Use page is NOT required since there are no auto-renewing subscriptions.
