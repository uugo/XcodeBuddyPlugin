# XcodeBuddyPlugin 

![usage](https://github.com/uugo/XcodeBuddyPlugin/blob/master/image/usage.png)

## Version

Latest Version: 1.0

![屏幕快照 2016-06-21 09.58.43](https://github.com/uugo/XcodeBuddyPlugin/blob/master/image/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202016-06-21%2009.58.43.png)

![屏幕快照 2016-06-21 09.59.17](https://github.com/uugo/XcodeBuddyPlugin/blob/master/image/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202016-06-21%2009.59.17.png)



## What can XcodeBuddy Plugin do ?

* connect to  `xcBuddy` App in your ipad
* send all the projects files to `xcBuddy` App of your ipad
* `open with xcBuddy` in right-click context menu, and view this file in `xcBuddy` App

xcBuddy App

![xcBuddy App](https://github.com/uugo/XcodeBuddyPlugin/blob/master/image/Slice%201.png)

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


