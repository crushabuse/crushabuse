#!/bin/bash
# name: this is your name obv
# it needs to be all lowercase, no trailing spaces, and needs to have quotes
# ❌: Joe Biden
# ❌: "joe Biden"
# ⚠️: "joe robinette biden" - not many know your middle name so be weary!!
# ✅: "joe biden"
# test it out with "joe biden", it'll work!
NAME="joe biden"
HASH=$(echo -n $NAME | sha256sum | awk '{print $1}')
TIMESTAMP=$(date +%s)
if [ -f ~/.crushabusets ]; then
    JSON=$(curl -s --no-progress-meter https://crushabuse.glitch.me/api/check/$HASH/$(cat ~/.crushabusets))
else
    JSON=$(curl -s --no-progress-meter https://crushabuse.glitch.me/api/check/$HASH)
fi
OS_NAME=$(uname -s)
SOUND=true # Plays the grindr notification sound if a crush is detected (default: false). Be weary, it's loud. Also requires sox
VERSION="1.0.0"
TARGET_VERSION=$(dig +short TXT updates.crushabuse.xyz | tr -d '"' | awk '{print $1}') # Set this to $TARGET_VERSION=(whatever the current ver) to disable

if [ "$VERSION" != "$TARGET_VERSION" ]; then
    echo "Please update crushabuse!"
fi
for item in $(echo "$JSON" | jq -c '.[]'); do
    permalink=$(echo "$item" | jq -r '.permalink')
    date=$(echo "$item" | jq -r '.date')
    if [ ! -f "/tmp/crushabusesound.mp3" ] && [ "$SOUND" = "true" ]; then
        wget -O /tmp/crushabusesound.mp3 https://cdn.jsdelivr.net/gh/crushabuse/crushabuse/grindr-notification-sound.mp3
    fi
    if command -v npx &>/dev/null; then
        if [ "$SOUND" = "true" ]; then
            play /tmp/crushabusesound.mp3
            npx --yes -p node-notifier-cli notify -t 'We found you a crush!' -m "Check $permalink for more details." --open $permalink
            echo $TIMESTAMP >~/.crushabusets
        else
            npx --yes -p node-notifier-cli notify -t 'We found you a crush!' -m "Check $permalink for more details." --open $permalink
            echo $TIMESTAMP >~/.crushabusets
        fi
    else
        if [[ "$OS_NAME" == "MINGW64" ]]; then
            echo "Please install Node.js."
        elif [[ "$OS_NAME" == "Linux" ]]; then
            if command -v notify-send &>/dev/null; then
                if [ "$SOUND" = "true" ]; then
                    play /tmp/crushabusesound.mp3
                    notify-send 'We found you a crush!' "Check $permalink for more details."
                    echo $TIMESTAMP >~/.crushabusets
                else
                    notify-send 'We found you a crush!' "Check $permalink for more details."
                    echo $TIMESTAMP >~/.crushabusets
                fi
                notify-send 'We found you a crush!' "Check $permalink for more details."
                echo $TIMESTAMP >~/.crushabusets
            else
                echo "Please install Node.js or you can also install libnotify(-bin), but that's ill-advised."
            fi
        elif [[ "$OS_NAME" == "Darwin" ]]; then
            if command -v terminal-notifier &>/dev/null; then
                if [ "$SOUND" = "true" ]; then
                    play /tmp/crushabusesound.mp3
                    terminal-notifier -title 'We found you a crush' -message 'Click this notification to open slack!' -open $permalink
                    echo $TIMESTAMP >~/.crushabusets
                else
                    terminal-notifier -title 'We found you a crush' -message 'Click this notification to open slack!' -open $permalink
                    echo $TIMESTAMP >~/.crushabusets
                fi
            else
                echo "Please install Node.js or install terminal-notifier via brew (or rubygems)."
            fi
        else
            echo "Please install Node.js."
        fi
    fi
done
