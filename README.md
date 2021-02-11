# adzerk-ios-sdk

## Requirements

Use of the Adzerk iOS SDK requires iOS 10.0 or later.

## Installation

Installation of the framework can be done manually by building and copying the framework into your project, or with automatically with Swift Package Manager (preferred), Carthage, or CocoaPods.

Note that for manual and Carthage framework imports you may have to specify "Embedded Content Contains Swift Code" to avoid getting a linker error during build. Another way to force Xcode to load the Swift libraries is to add a single Swift source file to your project.

### Swift Package Manager

Using Xcode, add a Swift Package in the Project Settings tab. Enter the URL https://github.com/adzerk/adzerk-ios-sdk.git and click Next. Choose your version and click continue to integrate it.

### Carthage

If you're using [Carthage](https://github.com/Carthage/Carthage), add this to your `Cartfile`:

```ruby
github "adzerk/adzerk-ios-sdk" ~> 2.0
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
pod 'adzerk-ios-sdk', '~> 2.0
```

Again, if you want to be on the latest master branch:

```ruby
use_frameworks!

pod 'adzerk-ios-sdk', github: 'adzerk/adzerk-ios-sdk', branch: 'master'
```

Then run `pod install` to download the code and integrate it into your project. You'll then open the pod-created workspace instead of your project to build.

## Usage

All API operations are done with an instance of [`DecisionSDK`](http://adzerk.github.io/adzerk-ios-sdk/Classes/DecisionSDK.html).

For most uses, a single Network ID and Site ID will be used for the entire application. If this is the case
you can configure it once in the `AppDelegate`:

```swift
@import AdzerkSDK

func applicationDidFinishLaunching(...) {
  DecisionSDK.defaultNetworkId = YOUR_NETWORK_ID
  DecisionSDK.defaultSiteId = YOUR_SITE_ID
}
```

For requests that need a different Network ID or Site ID, you can specify this on the individual placement request.

You can also set a custom host if you need to, up front, like this:

```swift
  DecisionSDK.host = "your custom host"
```

Note that the host is just the domain part of the reuqests. Do not include a scheme like `https://` in your custom hosts.

### Requesting Placements

To request a placement, you can build a type that conforms to `Placement` and specify the attributes you want to send.

There are two types of placements builtin:

- `StandardPlacement`
- `CustomPlacement`

You can use `CustomPlacement` if you need to send additional JSON data to the server.

For brevity, you can create placements using the `Placements` type:

```swift
let placement = Placements.standard(...)
```

To send the request:


```swift
// Assumes that the default network ID and site ID are already set on DecisionSDK

let sdk = DecisionSDK()
let placement = Placements.standard(divName: "div1", adTypes: [1])

sdk.request(placement: placement) { result in
	// gives you a Swift Result of type Result<PlacementResponse, AdzerkError>
}
```

_Note: completion blocks are called on the main queue. If you want to be called back on a different queue, you can pass this queue to the DecisionSDK initializer._

### Handling the Response

A placement request will accept a completion block that is handed an instance of `Result<PlacementResponse, AdzerkError>`.

Handle each case as appropriate for your application. In the case of `.success` you are given an `PlacementResponse`
that contains the decisions for each placement requested.

## GDPR Consent

Consent preferences can be specified when building a request. For example, to set GDPR consent for tracking in the European Union (this defaults to false):

```swift
var options = PlacementRequest<StandardPlacement>.Options()
options.consent = Consent(gdpr: false)
```

## Logging

By default, warnings and errors will be directed to `os_log`. You can configure your desired log level:

```swift
DecisionSDK.logger.level = .debug
```

## App Transport Security

Adzerk's API Server is compliant with App Transport Security.

## Building / Running Tests

You can run tests using the command line:

```
swift test
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

- 2.0: Rewritten for Swift, Swift Package Manager. This is a breaking change, as many of the types have evolved to more closely match Swift style.

- 1.2: Add support for configurable hostname overrides

- 1.1: Read/update GDPR consent

- 1.0.4: Objective-C compatibility fixes for placements and decisions.

- 1.0.3: Turns off logging by default, adds control over how/when to log to the console.

- 1.0.2: Can specify which queue the sdk calls you back on. Defaults to `DispatchQueue.main`

- 1.0: Swift 3 support

_Breaking change: The Objective-C status code was changed from `NSNumber *` to `NSInteger`, as Swift 3 no longer automatically maps `Int?` to `NSNumber *`._

- 0.4: Initial release
