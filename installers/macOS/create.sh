#! /bin/bash

# from: https://github.com/create-dmg/create-dmg

brew install create-dmg
create-dmg --volname Tricks --volicon drive.icns --background background.png --window-size 650 
380 --icon-size 140 --icon Tricks.app 150 180 --hide-extension "Tricks.app" --app-drop-link 
450 180 Tricks.dmg Tricks
