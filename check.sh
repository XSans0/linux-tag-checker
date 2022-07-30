#!/usr/bin/env bash
# Copyright ©2022 XSans02

# Function to show an informational message
msg() {
    echo -e "\e[1;32m$*\e[0m"
}

err() {
    echo -e "\e[1;31m$*\e[0m"
}

if [[ -z "$TELEGRAM_TOKEN" ]] || [[ -z "$CHANNEL_ID" ]]; then
    err "* Something is missing!"
fi

# Clone telegram source
git clone --depth=1 https://github.com/XSans02/Telegram Telegram

# Telegram Setup
TELEGRAM=Telegram/telegram

send_msg() {
  "${TELEGRAM}" -c "${CHANNEL_ID}" -H -D \
      "$(
          for POST in "${@}"; do
              echo "${POST}"
          done
      )"
}

TAG=$(cat 4.14-y)

wget https://android.googlesource.com/kernel/common/+/refs/heads/android-4.14-stable/Makefile -O tag.txt

if [[ ! -z "$(cat tag.txt | grep '<span class="lit">'$TAG'</span>')" ]];then
    msg "* New linux 4.14-stable detected"
    send_msg "<b>New linux 4.14-stable detected</b>" \
            "" \
            "<b>Version : </b><code>$TAG</code>" \
            "<b>Source : </b><a href='https://android.googlesource.com/kernel/common/+/refs/heads/android-4.14-stable'>android-4.14-stable</a>" \
            "" \
            "<b> When upstream?</b>"

    TAG=$(($TAG+1))
    echo "$TAG" > "4.14-y"
fi

# Git Configs
git config --global user.name "XSans0"
git config --global user.email "xsansdroid@gmail.com"

# Create & push commits
git add 4.14-y
git commit -sm "Update for next notification"
git push