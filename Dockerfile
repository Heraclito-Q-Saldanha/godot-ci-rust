FROM debian

# base

USER root
ENV HOME /root

ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		git \
		git-lfs \
		nano \
		build-essential \
		clang \
		cmake \
		wget \
		curl \
		unzip \
		openjdk-11-jdk-headless \
	&& apt-get clean \
	&& apt-get autoremove

# android sdk

ARG ANDROID_CMDLINE_URL=https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip
ARG ANDROID_SDK_ROOT=/opt/android
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
	&& cd /tmp \
    && wget -q ${ANDROID_CMDLINE_URL} -O android-commandline-tools.zip \
	&& unzip -q android-commandline-tools.zip \
    && mv cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm -rf android-commandline-tools.zip cmdline-tools/ && ls -a ${ANDROID_SDK_ROOT}

ENV PATH ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${PATH}

RUN mkdir -p ${ANDROID_SDK_ROOT}/sdk \
	&& yes | sdkmanager --licenses \
	&& yes | sdkmanager "build-tools;30.0.3" "platforms;android-31" "cmake;3.10.2.4988404" "ndk;21.4.7075529"

ARG ANDROID_KEYSTORE_DIR=$HOME/.android
RUN mkdir -p $ANDROID_KEYSTORE_DIR \
	&& cd $ANDROID_KEYSTORE_DIR \
	&& keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12

# rust

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH $HOME/.cargo/bin:$PATH

RUN rustup target add \
    x86_64-pc-windows-gnu \
    aarch64-linux-android \
    armv7-linux-androideabi \
    x86_64-linux-android \
    i686-linux-android \
    x86_64-unknown-linux-gnu \
    i686-unknown-linux-gnu

# godot

ENV GODOT_VERSION=3.5
ENV GODOT_DIR=/opt/godotengine
ARG GODOT_BASE_URL=https://downloads.tuxfamily.org/godotengine

RUN mkdir -p $GODOT_DIR \
	&& cd $GODOT_DIR \
	&& wget -nc -nv $GODOT_BASE_URL/$GODOT_VERSION/Godot_v$GODOT_VERSION-stable_linux_headless.64.zip \
	&& unzip -q *.zip \
	&& rm *.zip \
	&& ln -s Godot_v$GODOT_VERSION-stable_linux_headless.64 godot3 \
    && ln -s Godot_v$GODOT_VERSION-stable_linux_headless.64 godot

ENV PATH=$GODOT_DIR:$PATH

ARG GODOT_TEMPLATE_DIR=$HOME/.local/share/godot/templates
RUN mkdir -p $GODOT_TEMPLATE_DIR \
	&& cd $GODOT_TEMPLATE_DIR \
	&& wget -nc -nv $GODOT_BASE_URL/$GODOT_VERSION/Godot_v$GODOT_VERSION-stable_export_templates.tpz \
	&& unzip -q Godot_v$GODOT_VERSION-stable_export_templates.tpz \
	&& mv -v templates $GODOT_VERSION.stable \
	&& rm -v Godot_v$GODOT_VERSION-stable_export_templates.tpz

ARG GODOT_EDITOR_CONFIG_DIR=$HOME/.config/godot
ARG GODOT_EDITOR_CONFIG_FILENAME=editor_settings-3.tres

RUN mkdir -p $GODOT_EDITOR_CONFIG_DIR \
	&& cd $GODOT_EDITOR_CONFIG_DIR \
	&& godot -e -q \
	&& echo 'export/android/android_sdk_path = "/opt/android"' >> $GODOT_EDITOR_CONFIG_FILENAME \
	&& echo 'export/android/debug_keystore = "/root/.android/debug.keystore"' >> $GODOT_EDITOR_CONFIG_FILENAME \
	&& echo 'export/android/debug_keystore_user = "androiddebugkey"' >> $GODOT_EDITOR_CONFIG_FILENAME \
	&& echo 'export/android/debug_keystore_pass = "android"' >> $GODOT_EDITOR_CONFIG_FILENAME

