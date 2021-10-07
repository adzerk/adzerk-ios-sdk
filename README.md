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
github "adzerk/adzerk-ios-sdk" ~> 2.1.0
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
pod 'adzerk-ios-sdk', '~> 2.1.0
```

Again, if you want to be on the latest master branch:

```ruby
use_frameworks!

pod 'adzerk-ios-sdk', github: 'adzerk/adzerk-ios-sdk', branch: 'master'
```

Then run `pod install` to download the code and integrate it into your project. You'll then open the pod-created workspace instead of your project to build.

## Examples

### API Credentials & Required IDs

- Network ID: Log into [Adzerk UI](https://app.adzerk.com/) & use the "circle-i" help menu in upper right corner to find Network ID. Required for all SDK operations.
- Site ID: Go to [Manage Sites page](https://app.adzerk.com/#!/sites/) to find site IDs. Required when fetching an ad decision.
- Ad Type ID: Go to [Ad Sizes page](https://app.adzerk.com/#!/ad-sizes/) to find Ad Type IDs. Required when fetching an ad decision.
- User Key: UserDB IDs are [specified or generated for each user](https://dev.adzerk.com/reference/userdb#passing-the-userkey).

### Fetching an Ad Decision

```swift
import AdzerkSDK

// Demo network, site, & ad type IDs; find your own via the Adzerk UI!
DecisionSDK.defaultNetworkId = 23
DecisionSDK.defaultSiteId = 667480

let client = DecisionSDK()

var p = Placements.custom(divName: "div0", adTypes: [5])

var reqOpts = PlacementRequest<StandardPlacement>.Options()
reqOpts.userKey = "abc"
reqOpts.keywords = ["keyword1", "keyword2"]

client.request(placements: [p], options: reqOpts) {response in
  dump(response)
}

// or if using Swift 5.5

let response = await client.request(placements: [p], options: reqOpts)
dump(response)
```

### Distance Targeting

```swift
import AdzerkSDK

// Demo network, site, & ad type IDs; find your own via the Adzerk UI!
DecisionSDK.defaultNetworkId = 23
DecisionSDK.defaultSiteId = 667480

let client = DecisionSDK()

var p = Placements.custom(divName: "div0", adTypes: [5])

var reqOpts = PlacementRequest<StandardPlacement>.Options()
reqOpts.userKey = "abc"
reqOpts.additionalOptions = [
  "intendedLatitude": .float(35.91868),
  "intendedLongitude": .float(-78.96001),
  "radius": .float(50) // in km
]

client.request(placements: [p], options: reqOpts) { response in
  dump(response)
}
```

### Recording Impressions and Clicks

Use with the fetch ad example above.

#### Recording Impressions

```swift
// Impression pixel; fire when user sees the ad
client.request(placements: [p], options: reqOpts) {
    switch $0 {
    case .success(let response):
        for decision in response.decisions {
            print(decision.key)

            for selection in decision.value {
                dump(selection, maxDepth: 3)

                print("\nFiring impression pixel...")
                client.recordImpression(pixelURL: selection.impressionUrl!)
            }
        }

    case .failure(let error):
        print(error)
    }
}
```

#### Recording Clicks

```swift
// Click pixel; fire when user clicks on the ad
client.request(placements: [p], options: reqOpts) {
    switch $0 {
    case .success(let response):
        for decision in response.decisions {
            print(decision.key)

            for selection in decision.value {
                dump(selection, maxDepth: 3)

                print("\nFiring click pixel...")
                client.firePixel(url: selection.clickUrl!) { response in
                    // status: HTTP status code
                    print(response.statusCode)
                    // location: click target URL
                    print(response.location)
                }

                // or if using Swift 5.5

                let response = await client.firePixel(url: selection.clickUrl!)
                print(response.statusCode)
                print(response.location)
            }
        }

    case .failure(let error):
        print(error)
    }
}
```

Since events have no revenue by default, overriding revenue on events adds new revenue. For example:

```
client.firePixel(url: clickUrl, override: 0.5) { ...

```

Sets a new value of $0.50 for the event.


```
client.firePixel(url: clickUrl, additional: 1.0) { ...

```

Sets a value of $1.00 for the event, or adds an additional $1.00 if the event has already had revenue set.


```
client.firePixel(url: clickUrl, grossMerchandiseValue: 1.5) { ...

```

Sets the gross merchandise value of $1.50 for the event.


### UserDB: Reading User Record

```swift
import AdzerkSDK

// Demo network ID; find your own via the Adzerk UI!
DecisionSDK.defaultNetworkId = 23

let keyStore = UserKeyStoreKeychain()
keyStore.save(userKey: "abc")

let client = DecisionSDK(keyStore: keyStore)

client.userDB().readUser() {response in
  dump(response)
}

// or with Swift 5.5

let response = await client.userDB().readUser()
dump(response)
```

### UserDB: Setting Custom Properties

```swift
import AdzerkSDK

// Demo network ID; find your own via the Adzerk UI!
DecisionSDK.defaultNetworkId = 23

let keyStore = UserKeyStoreKeychain()
keyStore.save(userKey: "abc")

let client = DecisionSDK(keyStore: keyStore)

let props:[String: AnyCodable] = [
    "favoriteColor":  .string("blue"),
    "favoriteNumber": .int(42),
    "favoriteFoods":  .array([
        .string("strawberries"),
        .string("chocolate"),
    ])
]

client.userDB().postProperties(props) {response in
  dump(response)
}
```

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

#### Standard Placement

For brevity, you can create placements using the `Placements` type:

```swift
let placement = Placements.standard(...)
```

#### Custom Placement

You can use `CustomPlacement` if you need to send additional JSON data to the server:

```swift
let placement = Placements.custom(...)
placement.additionalOptions = [
  "arbitraryKey": .string("value")
]
```

This feature is useful for beta features or features added to the API that haven't been officially supported via the SDK yet.

#### Sending the Request

```swift
// Assumes that the default network ID and site ID are already set on DecisionSDK

let sdk = DecisionSDK()
let placement = Placements.standard(divName: "div1", adTypes: [1])

sdk.request(placement: placement) { result in
    // gives you a Swift Result of type Result<PlacementResponse, AdzerkError>
}
```

Like individual placements, you can send `additionalOptions` at the request level:

```swift
let sdk = DecisionSDK()
let placement = Placements.standard(divName: "div1", adTypes: [1])
let opts = PlacementRequest<StandardPlacement>.Options()
opts.additionalOptions = [
  "arbitraryKey": .string("value")
]

sdk.request(placement: placement, options: opts) { result in
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

- 2.1.0: Add general pixel firing support

- 2.0.2: Support additionalOptions to the CustomPlacement and PlacementRequest

- 2.0.1: Update visibility of some members to allow addiiton flexibility.

- 2.0: Rewritten for Swift, Swift Package Manager. This is a breaking change, as many of the types have evolved to more closely match Swift style.

- 1.2: Add support for configurable hostname overrides

- 1.1: Read/update GDPR consent

- 1.0.4: Objective-C compatibility fixes for placements and decisions.

- 1.0.3: Turns off logging by default, adds control over how/when to log to the console.

- 1.0.2: Can specify which queue the sdk calls you back on. Defaults to `DispatchQueue.main`

- 1.0: Swift 3 support

_Breaking change: The Objective-C status code was changed from `NSNumber *` to `NSInteger`, as Swift 3 no longer automatically maps `Int?` to `NSNumber *`._

- 0.4: Initial release
