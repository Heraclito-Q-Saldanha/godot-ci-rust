FROM docker.io/heraclitoqsaldanha/godot-ci:3.5.1

# rust

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y
ENV PATH /root/.cargo/bin:$PATH

RUN rustup target add \
    x86_64-pc-windows-gnu \
    aarch64-linux-android \
    armv7-linux-androideabi \
    x86_64-linux-android \
    i686-linux-android \
    x86_64-unknown-linux-gnu \
    i686-unknown-linux-gnu

RUN echo " \
[target.armv7-linux-androideabi] \n \
linker = \"$ANDROID_SDK_ROOT/ndk/21.4.7075529/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi29-clang\" \n \
[target.aarch64-linux-android] \n \
linker = \"$ANDROID_SDK_ROOT/ndk/21.4.7075529/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android29-clang\" \n \
[target.i686-linux-android] \n \
linker = \"$ANDROID_SDK_ROOT/ndk/21.4.7075529/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android29-clang\" \n \
[target.x86_64-linux-android] \n \
linker = \"$ANDROID_SDK_ROOT/ndk/21.4.7075529/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android29-clang\" \n \
" >> /root/.cargo/config
