# adzerk-ios-sdk

## Requirements

Use of the Adzerk iOS SDK requires iOS 8.0 or later.

## Installation

TODO

## Usage

All API operations are done with an instance of [`AdzerkSDK`](http://adzerk.github.io/adzerk-ios-sdk/Classes/AdzerkSDK.html).

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

### A Note About Objective-C

Objective-C does not support Swift Enums, so an alternative callback-based method is provided. If you're using this SDK from
and Objective-C project, you can request placements like this:

```objc
ADZPlacement *placement = [[ADZPlacement alloc] initWithDivName:@"div1" adTypes:@[@5]];
placement.zoneIds = @[@1];
    
AdzerkSDK *sdk = [[AdzerkSDK alloc] init];
[sdk requestPlacements:@[placement] options:nil success: ^void(ADZPlacementResponse *response) {
    NSLog(@"Response: %@", response);
} failure: ^void(NSNumber *statusCode, NSString *body, NSError *error) {
    NSLog(@"Failure:");
    NSLog(@"  Status Code: %@", statusCode);
    NSLog(@"  Response Body: %@", body);
    NSLog(@"  Error: %@", error);
}];
```

## Building / Running Tests

Use Xcode 7.0 or later. Ensure that command line tools are installed:

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

## Generating Docs

Docs are generated with [jazzy](https://github.com/Realm/jazzy) and are hosted on github pages. To install jazzy:

> `gem install jazzy` 

_If you're using system ruby, you'll probably need to prefix the above with `sudo`_.

All doc generation happens on a different detached branch.  Make sure your working copy is clean and switch to the other branch:

```
$ git checkout gh-pages
```

