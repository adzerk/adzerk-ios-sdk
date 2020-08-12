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
github "adzerk/adzerk-ios-sdk" ~> 1.2
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
pod 'adzerk-ios-sdk', '~> 1.2
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

_Note: completion blocks are called on the main queue. If you want to be called back on a different queue, you can pass this queue to the AdzerkSDK initializer._

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
an Objective-C project, you can request placements like this:

```objc
ADZPlacement *placement = [[ADZPlacement alloc] initWithDivName:@"div1" adTypes:@[@5]];
placement.zoneIds = @[@1];

AdzerkSDK *sdk = [[AdzerkSDK alloc] init];
[sdk requestPlacements:@[placement] options:nil success: ^void(ADZPlacementResponse *response) {
    NSLog(@"Response: %@", response);
} failure: ^void(NSInteger statusCode, NSString *body, NSError *error) {
    NSLog(@"Failure:");
    NSLog(@"  Status Code: %d", statusCode);
    NSLog(@"  Response Body: %@", body);
    NSLog(@"  Error: %@", error);
}];
```

## GDPR Consent

Consent preferences can be specified when building a request. For example, to set GDPR consent for tracking in the European Union (this defaults to false):

```swift
let options = ADZPlacementRequestOptions()
options.consent = ADZConsent(gdpr: false)
```

## Logging

By default, warnings and errors will be printed to the console. If you want to change this, you can edit your scheme and provide a launch argument:

![](https://benpublic.s3.amazonaws.com/adzerksdk/launcharguments.png)

```
-com.adzerk.sdk.loglevel <your desired log level>
```

The supported log levels:

| value      | level  | description     |
| ---------- | ------ | ----------------|
| 0          | off    | No logs will be printed to the console
| 1          | error  | Only errors will be output
| 2          | warn   | Errors and warnings will be output (This is the default value)
| 3          | debug  | verbose information (including HTTP response codes, bodies, etc) will be printed to the console

## iOS 9 App Transport Security

Adzerk's API Server is compliant with App Transport Security.

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

# Changelog

- 1.2: Add support for configurable hostname overrides

- 1.1: Read/update GDPR consent

- 1.0.4: Objective-C compatibility fixes for placements and decisions.

- 1.0.3: Turns off logging by default, adds control over how/when to log to the console.

- 1.0.2: Can specify which queue the sdk calls you back on. Defaults to `DispatchQueue.main`

- 1.0: Swift 3 support

_Breaking change: The Objective-C status code was changed from `NSNumber *` to `NSInteger`, as Swift 3 no longer automatically maps `Int?` to `NSNumber *`._

- 0.4: Initial release
