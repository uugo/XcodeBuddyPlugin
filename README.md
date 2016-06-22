# XcodeBuddyPlugin 

![usage](http://7xqvso.com1.z0.glb.clouddn.com/2016-06-21-usage.png)

## XcodeBuddyPlugin

Latest Version: 1.0

![屏幕快照 2016-06-21 09.58.43](http://7xqvso.com1.z0.glb.clouddn.com/2016-06-21-屏幕快照 2016-06-21 09.58.43.png)

![屏幕快照 2016-06-21 09.59.17](http://7xqvso.com1.z0.glb.clouddn.com/2016-06-21-屏幕快照 2016-06-21 09.59.17.png)


## What can XcodeBuddy Plugin do ?

* connect to  `xcBuddy` App in your ipad
* send all the projects files to `xcBuddy` App of your ipad
* `open with xcBuddy` in right-click context menu, and view this file in `xcBuddy` App

xcBuddy App
![xcBuddy App](http://7xqvso.com1.z0.glb.clouddn.com/2016-06-21-Slice 1.png)

## Install
Three methods:
1. use [Alcatraz plugin](https://github.com/alcatraz/Alcatraz),select `Package Manager` from the `window` menu in Xcode;
2. download from [this link](https://github.com/uugo/XcodeBuddyPlugin/releases) and move the plugin file to the path
 `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/`,
then restart Xcode;
3. clone this repo,build the project and it's done.


## Todo list
1. can get and use the Xcode's theme in your ipad;
2. code syntax highlighting same as your Xcode;
3. use Xcode to wake up ipad,;

## FAQ

#### Not work for new Xcode?
Please run this in your Terminal:

```
find ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins -name Info.plist -maxdepth 3 | xargs -I{} defaults write {} DVTPlugInCompatibilityUUIDs -array-add `defaults read /Applications/Xcode.app/Contents/Info.plist DVTPlugInCompatibilityUUID`
```
and remember to change the Xcode path /Applications/Xcode.app if you have a customize Xcode app name or folder like/Applications/Xcode-beta.app.

## Change Log

v1.0 (2016/06/21)

1. connect to  `xcBuddy` app in your ipad
2. send all the projects files to `xcBuddy` app of your ipad
3. `open with xcBuddy` in right-click context menu, and view this file in `xcBuddy` app


