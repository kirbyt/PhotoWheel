PhotoWheel
==========

PhotoWheel is a personal photo library app with a spin. With PhotoWheel, you can organize your favorite photos into albums, share photos with family and friends, view them on your TV using AirPlay and an Apple TV, and most importantly, gain hands-on experience with building an iPad app.

This app is presented in the book [Learning iPad Programming, A Hands-on Guild to Building Apps for the iPad][1]. Readers of the book are guided step by step building PhotoWheel from scratch as they learn the inns and outs of iPad programming using the latest version of iOS.

How To Build PhotoWheel
=======================

This project requires Xcode 4.5 or later, and iOS 6.

Here are the additional steps you must follow to build and run PhotoWheel on your iPad:

1. Add your Flickr App Key to the flickrAPIKey marco defined in AppKeys.h. Calls to the Flickr web services will not return data without this key.
2. Add your HockeyKit App Key to the HOCKEYKIT_BETA_APPKEY marco defined in AppKeys.h. You only need to do this if you wish to use HockeyApp with PhotoWheel.
3. Add your HockeyKit App Key to the HOCKEYKIT_LIVE_APPKEY marco defined in AppKeys.h. You only need to do this if you wish to use HockeyApp with PhotoWheel.

Bundle Display Name and ID
--------------------------

The bundle display name and id for PhotoWheel are defined in the User-Defined Settings section of the Build Settings for the PhotoWheel target. This approach is used to give the build a different name and id based on the build configuration (i.e., Debug, Release, AppStore, and Beta). This allows more than one copy of PhotoWheel to be installed on the device at the same time. For instance, you can have the AppStore version install and still install the Debug version for testing your changes.

iCloud Syncing
--------------

To enable iCloud syncing, you need to change the bundle id and the iCloud container id to values based on the reverse domain name you use for your apps.

The Book
========
[Learning iPad Programming][1] walks you through the process of building PhotoWheel (free on the App Store), a photo management and sharing app that leverages almost every aspect of iOS. With PhotoWheel, you can organize your favorite photos into albums, share photos with family and friends, view them on your TV using AirPlay and an Apple TV, and most importantly, gain hands-on experience with building an iPad app. As you build PhotoWheel, you’ll learn how to take advantage of the latest features in iOS 6 and Xcode, including Storyboarding, Collection Views, Automatic Reference Counting (ARC), and iCloud. Best of all, you’ll learn how to extend the boundaries of your app by communicating with web services. If you want to build apps for the iPad, Learning iPad Programming is the one book to get.

As you build PhotoWheel, you’ll learn how to:
 
- Install and configure Xcode on your Mac
- Master the basics of Objective-C, and learn about memory management with ARC
- Build a fully functional app that uses Core Data and iCloud for photo sharing and synchronization
- Use Xcode’s new Storyboard feature to quickly prototype a functional UI, and then extend that UI with code 
- Create multitouch gestures and integrate Core Animation for a unique UI experience
- Build custom views, and use view controllers to perform custom view transitions
- Add AirPrint, email, and AirPlay capabilities to your app
- Apply image filters and effects using Core Image
- Diagnose and fix bugs with Instruments
- Prepare your app for submission to the app store


License
=======

The source code for PhotoWheel is available for free under the [MIT license][2]. This license grants you the right to do anything you like with the source code. However, you are asked not to re-submit the app as is to Apple for App Store review. The authors have worked very hard creating the book and app so you can learn how to build your own iPad app. So please, don't be a dick and re-submit PhotoWheel as your own to the Apple.

   [1]: http://learnipadprogramming.com/
   [2]: LICENSE
