#!/usr/bin/env bash
# Copyright ©2022 XSans02

# Function to show an informational message
msg() {
    echo -e "\e[1;32m$*\e[0m"
}

err() {
    echo -e "\e[1;31m$*\e[0m"
}

# Environment checker
if [[ -z "$TELEGRAM_TOKEN" ]] || [[ -z "$TELEGRAM_CHAT" ]]; then
    err "* Something is missing!"
    exit
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
linux_msg(){
    send_msg "<b>[ $1 ] New linux-4.14 Series Available!</b>" \
                "" \
                "<b>Version : </b><code>v4.14.$TAG</code>" \
                "<b>Source : </b><a href='$2'>$3</a>" \
                "" \
                "<b> When upstream?</b>"
}

# Git Configs
git config --global user.name "XSans0"
git config --global user.email "xsansdroid@gmail.com"

TOTAL="0"
while [[ "$TOTAL" != "52" ]]; do
    # Check git
    TAG="$(cat git/4.14-y)"
    msg "* [ Git ] Checking..."
    if curl -s https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/Makefile?h=linux-4.14.y | grep -q "SUBLEVEL = $TAG"
    then
        msg "* New linux-4.14 detected"
        linux_msg "Git" "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/?h=linux-4.14.y" "linux-4.14.y"

        TAG=$((TAG + 1))
        echo "$TAG" > "git/4.14-y"

        # Create & push commits
        git add git/4.14-y
        git commit -sm "[Git] Update for next notification"
        git push
    fi

    # Check common with looping and tag + 1 per looping
    # This will fix issue for release with skips previous tag 
    TAG="$(cat common/4.14-y)"
    TRY_AGAIN="0"
    
    while [ "$TRY_AGAIN" != "5" ]; do
        msg "* [ Common ] Checking $TRY_AGAIN ..."

        if curl -s https://android.googlesource.com/kernel/common/+/refs/heads/android-4.14-stable/Makefile | grep -q '<span class="lit">'"$TAG"'</span>'
        then
            msg "* New linux-4.14 detected"
            linux_msg "Common" "https://android.googlesource.com/kernel/common/+/refs/heads/android-4.14-stable" "android-4.14-stable"

            TAG=$((TAG + 1))
            echo "$TAG" > "common/4.14-y"

            # Create & push commits
            git add common/4.14-y
            git commit -sm "[Common] Update for next notification"
            git push
        fi
        TAG=$((TAG + 1))
        TRY_AGAIN=$((TRY_AGAIN + 1))
    done

    sleep 1m
    TOTAL=$((TOTAL + 1))

    # Sync source
    git pull -r
done