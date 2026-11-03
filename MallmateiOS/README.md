# Mallmate for iPhone

Native SwiftUI app project for iOS 17 and later.

## Open and run

1. Open `Mallmate.xcodeproj` in Xcode.
2. Choose the **Mallmate** scheme and an iPhone simulator or connected iPhone.
3. For a physical iPhone, select your Apple development team under **Signing & Capabilities**, then press **Run**.

The app has Map, Directory, Parking, and Saved tabs. The complete store directory is bundled in `StoreDirectory.json`, grouped by floor from Sarath City Capital Mall’s official directory. The directory search and floor filters work offline. Store favorites and the saved parking bay are kept on the device.

The custom map and route overlay are schematic. The mall’s public floor-plan page is linked from the Map tab; exact store coordinates and live indoor positioning are not published as app-ready data in the directory, so the app does not claim a precise live position or turn-by-turn route.

## Directory source

[Sarath City Capital Mall — Store Directory](https://sarathcitycapitalmall.com/store-directory/)

[Sarath City Capital Mall — Floor Plans](https://sarathcitycapitalmall.com/map/)
