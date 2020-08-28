# LocalizeWiz iOS SDK

[![Version](https://img.shields.io/cocoapods/v/LocalizeWiz.svg?style=flat)](https://cocoapods.org/pods/LocalizeWiz)
[![License](https://img.shields.io/cocoapods/l/LocalizeWiz.svg?style=flat)](https://img.shields.io/github/license/localizewiz/wiz-ios-sdk?style=plastic)
[![Platform](https://img.shields.io/cocoapods/p/LocalizeWiz.svg?style=flat)](https://cocoapods.org/pods/LocalizeWiz)

The LocalizeWiz iOS SDK enables you to seamlessly integrate real time cloud based localizations into your iOS apps.

## Installation

### Cocoapods
To use Wiz with Cocoapods, first intall cocoapods if you do not already have it installed.
```shell
sudo gem install cocoapods
```

Then initialize the pod in your project directory
```shell
pod init
```

Open the `Podfile` in your project's root directory and add this line
```podfile
pod LocalizeWiz
```

Then run the following command to download and install the LocalizeWiz sdk in your project folder.
```shell
pod install
```

The LocalizeWiz SDK is now installed. Open the `.xcworkspace` file in your root project to continue.

### Carthage
You can also install the LocalizeWiz SDK with carthage.

If you do not already have carthage installed install carthate with homebrew:

```shell
brew install carthage
```

Create a `Cartfile` in the same directory where your `.xcodeproj` or `.xcworkspace` file is.

In the `Cartfile` you created, add this line:

```Cartfile
github "localizewiz/wiz-ios-sdk"
```

Run the following on the shell
```shell
carthage update
```

### Swift Package Manager
You can also install the LocalizeWiz SDK with Swift Package Manager (SPM).

## Initialization

Once the LocalizeWiz SDK is installed, the next thing to do is to initialize it in your project.
You will need an API key and a project ID to do this. If you have not already created a project, check out our [web dashboard guide](web-dashboard.md) on how to do this.

Add this to the top of your your `AppDelegate.swift` file to import the library and initialize the global instance:
```swift
import LocalizeWiz

let wiz = Wiz.sharedInstance
```
We recommend creating a `wiz` global variable that can be accessed from anywhere in your app code. If you don't want to create a global variable, you can create properties in each class you want to use wiz, usually view controllers. You just have to access the shared instance of wiz using `val wiz = Wiz.instance`.

Add this to the top of your your `AppDelegate.swift` file, add this inside your `application(didFinishLaunchingWithOptions:)` method:
``` swift 
wiz.setup(apiKey: "your-wiz-api-key", projectId: "your-project-id")
```

> If you don't already have an account, sign up on our [web dashboard](https://app.localizewiz.com/signup) and create a worksapce and project.


## Usage

We designed Wiz to be a drop in replacement for `NSLocalizedString`, so switching to `wiz` is easy.

Basic usage to set text of a control is as follows. Simply replace occurrences of `NSLocalizedString(key)` with 
`wiz.getString(key)`.

For example, if you have this code in your project: 
```swift
var myLabel = UILabel(...)
myLabel.text = NSLocalizedString("key to set", comment: "")
```

Replace that with the following:

```swift
var myLabel = UILabel(...)
myLabel.text = wiz.getString("key in localized")
```
This returns the string for the specified key, localized for the current locale, just like `NSLocalizedString`.
If the string is not found, or a localization does not exist for the current locale, the original string in the project
base language is returned. By using `Wiz` instead of `NSLocalizedString`, you can update strings on the dashboard and
resolved in the app without having to do an app update

> For details on setting up your projects check out our [docs](https://docs.localizewiz.com)
