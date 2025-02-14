#!/bin/bash

# Function to display a spinner while waiting
show_spinner () {
    local pid=$!
    local delay=0.25
    local spinner=('█■■■■' '■█■■■' '■■█■■' '■■■█■' '■■■■█')

    while [ "$(ps | grep $pid)" ]; do
        for i in "${spinner[@]}"; do
            echo -ne "\033[34m\r[*] $1...please wait.........\e[33m[\033[32m$i\033[33m]\033[0m   "
            sleep $delay
            printf "\b\b\b\b\b\b\b\b"
        done
    done
    printf "   \b\b\b\b\b"
    printf "\e[1;33m [Done]\e[0m"
    echo ""
}

# Function to install JDK 11 (Temurin)
install_jdk11 () {
    show_spinner "Downloading JDK 11" &
    JDK_URL="https://api.adoptopenjdk.net/v3/binary/latest/11/ga/linux/x64/jdk/hotspot/normal/adoptopenjdk"
    curl -sL "$JDK_URL" -o jdk.tar.gz
    tar xf jdk.tar.gz
    rm jdk.tar.gz
    export JAVA_HOME=$(pwd)/jdk-11.*
    export PATH="$JAVA_HOME/bin:$PATH"
}

# Function to download Gradlew
download_gradlew () {
    show_spinner "Downloading Gradlew" &
    GRADLEW_URL="https://github.com/gradle/gradle/releases/latest/download/gradle.zip"
    curl -sL "$GRADLEW_URL" -o gradle.zip
    unzip -q gradle.zip
    rm gradle.zip
    chmod +x gradle/bin/gradle
    export PATH="$(pwd)/gradle/bin:$PATH"
}

# Build the Android app using Gradle
build_app () {
    chmod +x gradlew
    ./gradlew build
}

# Main script
set -e # Exit script immediately if any command returns a non-zero status

# Update repositories using apt with the spinner
show_spinner "Updating Repositories" &
apt update > /dev/null 2>&1
wait # Wait for the spinner to finish

apt install -y curl tar unzip
install_jdk11
download_gradlew
build_app
