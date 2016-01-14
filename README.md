# YBAlertController

YBAlertController is a Swift library that provide a tidy action sheet and alert

[![CI Status](http://img.shields.io/travis/Yabuzaki/YBAlertController.svg?style=flat)](https://travis-ci.org/Yabuzaki/YBAlertController)
[![Version](https://img.shields.io/cocoapods/v/YBAlertController.svg?style=flat)](http://cocoapods.org/pods/YBAlertController)
[![License](https://img.shields.io/cocoapods/l/YBAlertController.svg?style=flat)](http://cocoapods.org/pods/YBAlertController)
[![Platform](https://img.shields.io/cocoapods/p/YBAlertController.svg?style=flat)](http://cocoapods.org/pods/YBAlertController)

## Demo
![Demo](https://raw.githubusercontent.com/wiki/yabuzaki/YBAlertController/images/demo0.gif)  ![Demo](https://raw.githubusercontent.com/wiki/yabuzaki/YBAlertController/images/demo1.gif)
## Easy to use

```swift
let alertController = YBAlertController(title: "Menu", message: "Message", style: .ActionSheet)
// let alertController = YBAlertController(style: .ActionSheet)

// add a button
alertController.addButton(UIImage(named: "comment"), title: "Comment", target: self, selector: Selector("tap"))
// add a button with closure
alertController.addButton(UIImage(named: "tweet"), title: "Tweet", action: {
	print("button tapped")
})
// add a button (No image)
alertController.addButton("Open in Safari", target: self, selector: Selector("tap"))

// if you use a cancel Button, set cancelButtonTitle
// alertController.cancelButtonTitle = "Cancel"   
         
// show alert
alertController.show()

func tap() {
	print("tap")
}
```

## Customize

#### button icon color
```swift
alertController.buttonIconColor = UIColor.blackColor()
```

#### Overlay color
```swift
alertController.overlayColor = UIColor(red:235/255, green:245/255, blue:255/255, alpha:0.7)
```

#### Title
```swift
// if title is nil or empty, the title Label is hidden
alertController.title = "Title"
alertController.titleFont = UIFont(name: "Avenir Next", size: 15)
alertController.titleTextColor = UIColor.blueColor()
```

#### Message
```swift
// if message is nil or empty, the message Label is hidden
alertController.message = "Message"
alertController.messageFont = UIFont(name: "Avenir Next", size: 15)
alertController.messageTextColor = UIColor.blueColor()
```

#### Cancel Button
```swift
// if cancelButtonTitle is nil or empty, the cancel button is hidden
alertController.cancelButtonTitle = "Cancel"
alertController.cancelButtonFont = UIFont(name: "Avenir Next", size: 15)
alertController.cancelButtonTextColor = UIColor.blueColor()
```

#### Button
```swift
alertController.buttonFont = UIFont(name: "Avenir Next", size: 15)
alertController.buttonTextColor = UIColor.blueColor()
```
#### Touch outside the alert to dismiss
```swift
alertController.touchingOutsideDismiss = true
// default, Alert:false ActionSheet:true
```

#### Not using a animation
```swift
alertController.animated = false
```

## Installation

### Manual
Just drag `YBAlertController.swift` to your project.

### Cocoapods
YBAlertController is available through [CocoaPods](http://cocoapods.org). 
To install it, simply add the following line to your Podfile:

```ruby
pod "YBAlertController"
```

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
* iOS 7.0+

## Author

Yabuzaki
http://twitter.com/planet12app
http://appstore.com/yutayabuzaki

## License

YBAlertController is available under the MIT license. See the LICENSE file for more info.
