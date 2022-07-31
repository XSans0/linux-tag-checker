#!/usr/bin/env bash
# Copyright ©2022 XSans02

# Function to show an informational message
msg() {
    echo -e "\e[1;32m$*\e[0m"
}

err() {
    echo -e "\e[1;31m$*\e[0m"
}

if [[ -z "$TELEGRAM_TOKEN" ]] || [[ -z "$TELEGRAM_CHAT" ]]; then
    err "* Something is missing!"
fi

# Clone telegram source
git clone --depth=1 https://github.com/XSans02/Telegram Telegram

# Telegram Setup
TELEGRAM=Telegram/telegram

send_msg() {
  "${TELEGRAM}" -H -D \
      "$(
          for POST in "${@}"; do
              echo "${POST}"
          done
      )"
}

TAG=$(cat 4.14-y)
TOTAL="0"

while [[ "$TOTAL" != "52" ]]; do

    wget https://android.googlesource.com/kernel/common/+/refs/heads/android-4.14-stable/Makefile -O tag.txt

    if [[ ! -z "$(cat tag.txt | grep '<span class="lit">'$TAG'</span>')" ]];then
        msg "* New linux 4.14-stable detected"
        send_msg "<b>New linux 4.14-stable release available!</b>" \
                "" \
                "<b>Version : </b><code>4.14.$TAG</code>" \
                "<b>Source : </b><a href='https://android.googlesource.com/kernel/common/+/refs/heads/android-4.14-stable'>android-4.14-stable</a>" \
                "" \
                "<b> When upstream?</b>"

        TAG=$(($TAG+1))
        echo "$TAG" > "4.14-y"

        # Git Configs
        git config --global user.name "XSans0"
        git config --global user.email "xsansdroid@gmail.com"

        # Create & push commits
        git add 4.14-y
        git commit -sm "Update for next notification"
        git push
    fi
    rm -rf tag.txt
    sleep 1m
    TOTAL=$(($TOTAL+1))
done