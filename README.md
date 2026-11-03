# Mallmate

Mallmate is a native iPhone mall guide prototype for Sarath City Capital Mall. Its Store Directory tab includes the full floor-grouped tenant list from the mall’s official directory.

## Run the iPhone app

Open [`MallmateiOS/Mallmate.xcodeproj`](MallmateiOS/Mallmate.xcodeproj) in Xcode, choose the **Mallmate** scheme and an iPhone simulator, then press **Run**. For a physical iPhone, select your Apple development team under **Signing & Capabilities**.

The app includes floor-filtered store search, a schematic map, service shortcuts, saved places, parking bay saving, and a Wi-Fi access guide. Favorites and the saved parking bay persist on the device.

The official store directory provides tenant names grouped through Sixth Floor, while its floor-plan page lists Lower Ground through Fifth Floor plus Basement / Parking. The in-app map is marked schematic; it does not claim exact shop coordinates or live indoor positioning. Those need verified map geometry and an indoor location feed from the mall.

## Browser prototype

The workspace also contains a responsive browser version. Run `python3 -m http.server 8000` from this folder and open [http://localhost:8000](http://localhost:8000).

## Mall references

- [Official Store Directory](https://sarathcitycapitalmall.com/store-directory/)
- [Official Floor Plans](https://sarathcitycapitalmall.com/map/)
