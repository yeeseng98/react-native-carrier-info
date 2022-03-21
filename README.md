# React Native Carrier Info

Note: 
- This repo is an unmaintained fork with additional functions to fetch SIM carrier identity via Carrier Name + Mobile Carrier Code + Mobile Network Code.
- Multi-SIM and eSIM behaviour is supported.

Due to security reasons in both OS, the actual SIM ICCID can no longer be fetched after certain API versions. Hence, the getIccid() function differentiates based on OS version.

Currently, the method functions using APIs below:
```js
Android Version:
<= 9 TelephonyManager
10 SubscriptionManager
11 Custom ID generation with Carrier Name + MCC + MNC with SubscriptionManager
(Physical SIM always take primary slot)

iOS Version:
<= 11 Custom ID generation with Carrier Name + MCC + MNC with subscriberCellularProvider
>= 12 Custom ID generation with Carrier Name + MCC + MNC with serviceSubscriberCellularProviders
(eSim seems to always take primary slot based on testing, but this is not confirmed)
```
React Native module bridge to obtain information about the user’s home cellular service provider.

Makes use of the following native classes:

- iOS
  - [CTTelephonyNetworkInfo](https://developer.apple.com/library/prerelease/ios/documentation/NetworkingInternet/Reference/CTTelephonyNetworkInfo/index.html#//apple_ref/occ/cl/CTTelephonyNetworkInfo)
  - [CTCarrier](https://developer.apple.com/library/prerelease/ios/documentation/NetworkingInternet/Reference/CTCarrier/index.html#//apple_ref/doc/c_ref/CTCarrier)
- Android
  - [TelephonyManager](https://developer.android.com/reference/android/telephony/TelephonyManager.html)

## Version

### 1.0.0

- Android support
- Promosify all APIs
- RN 0.47 support

## API

**All APIs are async functions**

### allowsVOIP (iOS only)

```javascript
boolean allowsVOIP() - Indicates if the carrier allows VoIP calls to be made on its network.
```

- If you configure a device for a carrier and then remove the SIM card, this property retains the Boolean value indicating the carrier’s policy regarding VoIP.
- Always return `true` on Android.

### carrierName

```js
string carrierName() - The name of the user’s home cellular service provider.
```

- This string is provided by the carrier and formatted for presentation to the user. The value does not change if the user is roaming; it always represents the provider with whom the user has an account.
- If you configure a device for a carrier and then remove the SIM card, this property retains the name of the carrier.
- The value for this property is 'nil' if the device was never configured for a carrier.

### isoCountryCode

```js
string isoCountryCode() - The ISO country code for the user’s cellular service provider.
```

- This property uses the ISO 3166-1 country code representation.
- The value for this property is 'nil' if any of the following apply:
  - The device is in Airplane mode.
  - There is no SIM card in the device.
  - The device is outside of cellular service range.

### mobileCountryCode

```js
string mobileCountryCode() - The mobile country code (MCC) for the user’s cellular service provider.
```

- MCCs are defined by ITU-T Recommendation E.212, “List of Mobile Country or Geographical Area Codes.”
- The value for this property is 'nil' if any of the following apply:
  - There is no SIM card in the device.
  - The device is outside of cellular service range.
- The value may be 'nil' on hardware prior to iPhone 4S when in Airplane mode.

### mobileNetworkCode

```js
string mobileNetworkCode() - The mobile network code (MNC) for the user’s cellular service provider.
```

- The value for this property is 'nil' if any of the following apply:
  - There is no SIM card in the device.
  - The device is outside of cellular service range.
- The value may be 'nil' on hardware prior to iPhone 4S when in Airplane mode.

### mobileNetworkOperator

```js
string mobileNetworkOperator() - return MCC + MNC, e.g 46697
```

## Getting Started (and running the demo project)

### iOS

1. From inside your project run `npm install react-native-carrier-info --save`
2. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
3. Go to `node_modules/react-native-carrier-info/ios` and add `RNCarrierInfo.xcodeproj`
4. In XCode, in the project navigator, select your project. Add `libRNCarrierInfo.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
5. Click `RNCarrierInfo.xcodeproj` in the project navigator and go the `Build Settings` tab. Make sure 'All' is toggled on (instead of 'Basic'). Look for `Header Search Paths` and make sure it contains both `$(SRCROOT)/../react-native/React` and `$(SRCROOT)/../../React` - mark both as `recursive`.
6. Set up the project to run on your device (iOS simulator does not report cellular provider info)
7. Run your project (`Cmd+R`)

### Android

- **app/build.gradle**

```gradle

dependencies {
  ...
  compile project(':react-native-carrier-info') <-- add this
  ...

}

```

- **settings.gradle**

```gradle

include ':react-native-carrier-info'
project(':react-native-carrier-info').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-carrier-info/android')

```

- **MainApplication.java**

```gradle

...
import com.ianlin.RNCarrierInfo.RNCarrierInfoPackage; <-- add this
...

@Override
protected List<ReactPackage> getPackages() {
  return Arrays.<ReactPackage>asList(
    new MainReactPackage(),
    ...
    new RNCarrierInfoPackage(), <-- add this
    ...
  );
}

```

## Usage Example

```js

import CarrierInfo from 'react-native-carrier-info';

// inside your code where you would like to retrieve carrier info
CarrierInfo.allowsVOIP()
.then((result) => {
  Alert.alert('Allows VoIP', JSON.stringify(result));
});

CarrierInfo.carrierName()
.then((result) => {
  Alert.alert('Carrier Name', result);
});

CarrierInfo.isoCountryCode()
.then((result) => {
  Alert.alert('ISO', result);
});

CarrierInfo.mobileCountryCode()
.then((result) => {
  Alert.alert('MCC', result);
});

CarrierInfo.mobileNetworkCode()
.then((result) => {
  Alert.alert('MNC', result);
});

CarrierInfo.mobileNetworkOperator()
.then((result) => {
  Alert.alert('MCC + MNC', result);
});

```

There is an example project supplied with the repo in the RNCarrierInfoDemo folder. The sample app needs to be run on a device as the simulator does not report cellular provider info.

## Original Author:

[![anarchicknight](https://avatars1.githubusercontent.com/u/11375227?s=48)](https://github.com/anarchicknight)

## License

[ISC License](https://opensource.org/licenses/ISC) (functionality equivalent to **MIT License**)
