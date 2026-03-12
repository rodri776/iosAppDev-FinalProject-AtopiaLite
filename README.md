# Atopia-Lite

MPCS51030 Final Project (Winter 2026)

## Team
- Juniper Rodriguez
- Alina Li

## Executive Summary
Atopia-Lite is a social discovery iOS app that helps users find nearby people with similar interests using a guided onboarding flow, an interactive interest graph ("The Cluster"), and similarity scoring against user profiles. The app addresses the problem of making meaningful local connections by turning abstract interests into structured datapoints, then using on-device semantic similarity and optional CloudKit sync to surface better matches. In the App Store landscape, it fits as a social/lifestyle utility focused on lightweight profile building and interest-based introductions. Technically, the app uses SwiftUI for UI, local persistence with `UserDefaults` and Keychain, optional iCloud public database syncing through CloudKit, Core Location for city/state onboarding, and MapKit/EventKit/MessageUI for creating and sending hangout invites.

## App Store Style Metadata
- Category: Social Networking (suggested)
- Age Group: 12+ (suggested, user-generated messaging/contacts context)
- Keywords (<=100 chars): social, interests, matching, nearby, friends, hangout, graph, discovery, profile, map
- Description: See `MarketingMaterials/rodri776_marketing.pdf`
- Executive one-pager: See `MarketingMaterials/rodri776_executive.pdf`
- App Preview video: `MarketingMaterials/AtopiaLite_Demo.mp4`

## Core Features
- Authentication with local account storage and optional credential save in Keychain.
- Multi-step onboarding:
  - Location capture (city/state/neighborhood)
  - Contacts step
  - Interest selection via The Cluster
- Interactive graph-based interest picker with recommendation generation.
- Match list and map-based discovery views.
- Profile page with saved datapoints.
- "Create Hangout" flow with location search, calendar event creation, and SMS invite composition.
- Splash screen at launch with app/developer names; dismisses after ~2s or on tap.
- "Rate this App" custom alert shown on the 3rd app launch.
- Settings.bundle support with developer and version metadata.

## Technical Notes
- Language/UI: Swift 5 + SwiftUI
- Minimum deployment target: iOS 26.2
- Data model: Local user model + interest datapoint hierarchy from embedded JSON
- Local persistence:
  - `UserDefaults` for settings, launch counters, onboarding/profile state
  - Keychain for credential storage
- Cloud sync (optional): CloudKit public database (`iCloud.Juniper.Atopia-Lite`)

## Framework Usage
No third-party frameworks are used in this project.

Apple frameworks used:
- SwiftUI
- Foundation
- CloudKit
- CryptoKit
- CoreLocation
- MapKit
- EventKit
- MessageUI
- NaturalLanguage
- Contacts (usage description configured)
- UIKit (where required by representables/lifecycle notifications)

## Third-Party Warning Policy
- Third-party framework warnings: N/A (no third-party dependencies).
- If third-party dependencies are added later, known warnings/issues must be linked here.

## Rubric Coverage Notes
- Settings.bundle included at `Atopia-Lite/Settings.bundle`.
- User preferences registered at app launch (`version_preference`, `created_by_preference`).
- `Initial Launch` (`Date`) is set on first launch.
- Launch counter is persisted and used to trigger 3rd-launch rating alert.
- Critical app flow events are logged with prefixed console tags (for onboarding, auth, profile, graph, cloud sync, map actions).
- Accessibility labels/hints are added across custom controls and modal surfaces.
- Background/foreground behavior is handled for graph physics loop.

## Build and Run
1. Open `Atopia-Lite/Atopia-Lite.xcodeproj` in Xcode.
2. Select scheme `Atopia-Lite`.
3. Use an iOS device or simulator compatible with iOS 26.2 SDK.
4. Build and run.

Notes:
- CloudKit operations require proper iCloud capability setup/signing for the bundle identifier.
- In restricted CI/sandbox environments without simulator runtime services, asset catalog build steps can fail even if project code is valid.

## Repository Deliverables
- Application source: `Atopia-Lite/`
- Marketing materials: `MarketingMaterials/`
  - `rodri776_marketing.pdf`
  - `rodri776_executive.pdf`
  - `AtopiaLite_Demo.mp4`

## Known Gaps / Follow-up Before Final Submission
- Re-run a full clean build in local Xcode and confirm zero project warnings.
- Perform and document a final VoiceOver accessibility audit on physical device.
- If targeting iPhone-only for grading scope, set target device family accordingly in project settings.
