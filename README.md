# adzerk-ios-sdk

## Requirements

Use of the Adzerk iOS SDK requires iOS 8.0 or later.

## Installation

Installation of the framework can be done manually by building and copying the framework into your project, or with
automatically with Carthage or CocoaPods.

Note that for manual and Carthage framework imports you may have to specify "Embedded Content Contains Swift Code" to avoid getting a linker error during build. Another way to force Xcode to load the Swift libraries is to add a single Swift source file to your project.

### Carthage

If you're using [Carthage](https://github.com/Carthage/Carthage), add this to your `Cartfile`:

```ruby
github "adzerk/adzerk-ios-sdk" ~> 0.2
```

If you want to be on the bleeding edge, you can specify the `master` branch:

```ruby
github "adzerk/adzerk-ios-sdk" "master"
```

Then run `carthage update` to fetch and build the framework. You can find the framework in the `Carthage` folder, and you can add
this to your project manually.

### CocoaPods

If you're using [CocoaPods](https://cocoapods.org), add this to your `Podfile`:

```ruby
pod 'adzerk-ios-sdk', '~> 0.2'
```

Again, if you want to be on the latest master branch:

```ruby
use_frameworks!

pod 'adzerk-ios-sdk', github: 'adzerk/adzerk-ios-sdk', branch: 'master'
```

Then run `pod install` to download the code and integrate it into your project. You'll then open the pod-created workspace instead of your project to build.

## Usage

All API operations are done with an instance of [`AdzerkSDK`](http://adzerk.github.io/adzerk-ios-sdk/Classes/AdzerkSDK.html).

For most uses, a single Network ID and Site ID will be used for the entire application. If this is the case
you can configure it once in the `AppDelegate`:

```swift
@import AdzerkSDK

func applicationDidFinishLaunching(...) {
  AdzerkSDK.defaultNetworkId = YOUR_NETWORK_ID
  AdzerkSDK.defaultSiteId = YOUR_SITE_ID
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

## iOS 9 App Transport Security

If you're building for iOS 9, you'll notice that requests fail unless you configure your `Info.plist` properly. Our team is currently working to upgrade our servers to avoid this configuration in the future. In the meantime, you'll need
to add the following exceptions for `engine.adzerk.net`:

- `NSExceptionMinimumTLSVersion` to `TLSv1.0`
- `NSExceptionRequiresForwardSecrecy` to `NO`

For more information on App Transport Security, see [Apple's Tech Note](https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/). For a live example, see the sample project's [Info.plist](https://raw.githubusercontent.com/adzerk/adzerk-ios-sdk/master/SampleApp/SampleApp/Info.plist?token=AADnBOuU-Qoxzb2WLO3_YdG2NIEw9HOGks5WCqgGwA%3D%3D).

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

```
$ gem install jazzy
```

_If you're using system ruby, you'll probably need to prefix the above with `sudo`_.

All doc generation happens on a different detached branch. Make sure your working copy is clean, close Xcode, and switch to the `gh-pages` branch:

```
$ git checkout gh-pages
```

Once there the content of the working directory becomes the static HTML site. Run the `generate_docs.sh` script to copy the latest version of the project from the `master` branch and run jazzy on it to generate the doc HTML:

```
$ ./generate_docs.sh
```

Once done, commit changes and push to github:

```
$ git add .
$ git commit -m "Update docs"
$ git push
```

After a few seconds, your changes will be live on [https://adzerk.github.io/adzerk-ios-sdk](https://adzerk.github.io/adzerk-ios-sdk).

# License

This SDK is released under the Apache 2.0 license. See [LICENSE](https://github.com/adzerk/adzerk-ios-sdk/tree/master/LICENSE) for more information.
