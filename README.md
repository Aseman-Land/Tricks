# Tricks

Tricks is a social network for programmers to share their tricks and tips with each others. It's free, open-source and released under the GPLv3 license.

![](https://raw.githubusercontent.com/Aseman-Land/Tricks/main/images/image.jpeg)

You can build and run tricks on smart phones like iOS and Androids or on the Linux, Windows or macOS.

## How to Build

### Dependencies

Tricks client depended on below library and modules.

#### Required Dependencies

- Qt 5.15.2 or newer [ [Source](https://download.qt.io/official_releases/qt/5.15/5.15.4/single/), [Binary Package](https://download.qt.io/official_releases/online_installers/)]
- QtAseman 3.1.5 or newer [[Git Repository](https://github.com/Aseman-Land/QtAseman)]

#### Recommended Dependencies

- KDE Syntaxt Highlighting [[Git Repository](https://github.com/KDE/syntax-highlighting)]
  -> For syntax highlighter and theme support on the code area.

#### Optional Dependencies

- QtFirebase [[Git Repository](https://github.com/Larpon/QtFirebase)]
  -> For Push notification support. You not needs to clone it. just clone it using `git submodule update --init --recursive` command on the Tricks source directory.

- Firebase C++ SDK [[Git Repository](https://github.com/firebase/firebase-cpp-sdk), [Binary Package](https://firebase.google.com/download/cpp)]
- Firebase iOS SDK 8.15 or older (for iOS only) [[Git Repository](https://github.com/firebase/firebase-ios-sdk), [Binary Packages](https://github.com/firebase/firebase-ios-sdk/releases/download/v8.15.0/Firebase.zip)]

### API Token

You have two choice to get token.

- **If you build Tricks for personal usages**, You do not needs any token. Just build it and use it for your personal usage. Trick server will generate a personal and limited token for you automatically and linked it to your account.
- **If you want to build Tricks for you and don't allow others to use it**, use your username instaed of token.
- **If you build Tricks for public usage**, Just contact us. We'll create and send you a token to use for public build.

### Setup Firebase (Android/iOS)

To setup firebase support extract firebase-cpp-sdk somewhere and point `FIREBASE_CPP_SDK_DIR` env to it:

```bash
export FIREBASE_CPP_SDK_DIR=/path/to/firebase_cpp_sdk
```

On the iOS you needs to download firebase-ios-sdk and point `FIREBASE_FRAMEWORKS_ROOT` to it too:

```bash
export FIREBASE_FRAMEWORKS_ROOT=/path/to/firebase_ios_sdk
```

### Build

To build Tricks just clone it and build it using QtCreator. You can also build it from command line using below commands:

```bash
git clone https://github.com/Aseman-Land/Tricks --recursive --depth 1
cd Tricks
mkdir build && cd build
qmake -r .. APP_SECRET_ID="YOUR_API_TOKEN" CONFIG+="qtquickcompiler"
make -j4
make install
```

#### Build from AUR

To build the project from AUR, simply install the [tricks](https://aur.archlinux.org/packages/tricks) package. It will clone and build the project with it's dependencies and package them for you on your computer.

```bash
yay -S tricks
```
