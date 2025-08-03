# Flutter Development Environment with Android Support - Windows/WSL2 Compatible
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Set environment variables
ENV FLUTTER_HOME=/opt/flutter
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_NDK_HOME=/opt/android-sdk/ndk/27.0.12077973
ENV PATH="$PATH:$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/ndk/27.0.12077973"
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV DOCKER_BUILDKIT=1

# Install system dependencies in optimized layers
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install audio dependencies - Windows/WSL2 compatible
RUN apt-get update && apt-get install -y \
    alsa-utils \
    alsa-oss \
    libasound2 \
    libasound2-plugins \
    libasound2-dev \
    portaudio19-dev \
    && rm -rf /var/lib/apt/lists/*

# Install build tools in separate layer
RUN apt-get update && apt-get install -y \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-12-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Java and Android dependencies in separate layer
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    lib32stdc++6 \
    lib32z1 \
    libc6-dev-i386 \
    libglu1-mesa \
    qemu-kvm \
    bridge-utils \
    cpu-checker \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js LTS (for Claude Code) - separate layer for caching
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome - separate layer
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Create Android SDK directory structure
RUN mkdir -p $ANDROID_HOME/cmdline-tools

# Download Android SDK command line tools - separate layer for caching
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip \
    && unzip -q commandlinetools-linux-10406996_latest.zip -d $ANDROID_HOME/cmdline-tools \
    && mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest \
    && rm commandlinetools-linux-10406996_latest.zip

# Accept Android licenses first (separate layer)
RUN yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses

# Install core Android SDK packages (separate layer)
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "platforms;android-33"

# Install build tools (separate layer)
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
    "build-tools;34.0.0" \
    "build-tools;33.0.1"

# Install emulator and system images (separate layer - largest downloads)
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
    "emulator" \
    "system-images;android-34;google_apis;x86_64"

# Install NDK (separate layer - very large download)
RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
    "ndk;27.0.12077973"

# Clone Flutter SDK - separate layer for caching
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# Install Claude Code globally - separate layer
RUN npm install -g @anthropic-ai/claude-code

# Set ownership for vscode user
RUN chown -R vscode:vscode $FLUTTER_HOME $ANDROID_HOME

# Switch to vscode user for remaining operations
USER vscode

# Configure Flutter - separate layer
RUN flutter config --enable-web \
    && flutter config --enable-linux-desktop \
    && flutter config --enable-android \
    && flutter config --android-sdk $ANDROID_HOME

# Precache Flutter artifacts - separate layer
RUN flutter precache --web --linux --android

# Create Android emulator - separate layer
RUN echo "no" | $ANDROID_HOME/cmdline-tools/latest/bin/avdmanager create avd \
    -n "Pixel_7_API_34" \
    -k "system-images;android-34;google_apis;x86_64" \
    -d "pixel_7"

# Configure emulator for Windows/WSL2 with audio
RUN mkdir -p ~/.android && \
    echo "PlayStoreImage.enabled=false" >> ~/.android/advancedFeatures.ini && \
    echo "audio.enabled=1" >> ~/.android/advancedFeatures.ini && \
    echo "hw.audioInput=yes" >> ~/.android/advancedFeatures.ini && \
    echo "hw.audioOutput=yes" >> ~/.android/advancedFeatures.ini && \
    # Update AVD config for audio when it exists \
    mkdir -p ~/.android/avd/Pixel_7_API_34.avd || true

# Set working directory
WORKDIR /workspace

# Expose ports for development
EXPOSE 8080 3000 5554 5555