# adzerk-ios-sdk

## Requirements

Use of the Adzerk iOS SDK requires iOS 8.0 or later.

## Installation

TODO

## Usage

All API operations are done with an instance of `[AdzerkSDK](http://adzerk.github.io/adzerk-ios-sdk/Classes/AdzerkSDK.html)`.

For most uses, a single Network ID and Site ID will be used for the entire application. If this is the case
you can configure it once in the `AppDelegate`:

```swift
@import AdzerkSDK

func applicationDidFinishLaunching(...) {
  AdzerkSDK.defaultNetworkId = YOUR_NETWORK_ID
  AdzerkSDK.deffaultSiteId = YOUR_SITE_ID
}
```

For requests that need a different Network ID or Site ID, you can specify this on the individual placement request.

### Requesting Placements

To request a placement, you can build an instance of `ADZPlacement` and specify the attributes you want to send:

```swift
// Assumes that the default network ID and site ID are already set on AdzerkSDK
var placement = ADZPlacement(divName: "div1", adTypes: [1])! 
placement.zoneIds = [3, 4, 5]

sdk.requestPlacements([placement]) { response in
  // handle response
}
```

### Handling the Response

A placement request will accept a completion block that is handed an instance of `ADZResponse`. This is 
a Swift enum that will indicate success or failure.

```swift
sdk.requestPlacements([placement]) { response in
  switch response {
    case .Success(let placements): // ...
    case .BadRequest(let httpStatusCode, let responseBody): //...
    case .BadResponse(let responseBody): //...
    case .Error(let error): //..
  }
}
```

Handle each case as appropriate for your application. In the case of `.Success` you are given an `ADZPlacementResponse`
that contains the decisions for each placement requested.

## Building / Running Tests

Use Xcode 6.4 or later. Ensure that command line tools are installed:

```
xcode-select --install
```

[xctool](http://github.com/facebook/xctool) is used to build from the command line and give pretty output.  Install it with [homebrew](http://brew.sh):

```
brew install xctool
```

You can build and run tests with the provided build script:

```
./build.sh
```
