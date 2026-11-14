# Stage 1: Install cross compilers and create a shim for MSVC-specific headers and macros for Cross-compile for RG353V (RK3566 / Cortex-A55) and DE10-Nano (Cyclone V / Cortex-A9)
FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc-arm-linux-gnueabihf \
    libc6-dev-armhf-cross \
    gcc-aarch64-linux-gnu \
    libc6-dev-arm64-cross \
    ca-certificates \
    autoconf \
    automake \
    libtool \
    pkg-config \
    make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

# Create a Linux/GCC compatibility shim for MSVC-specific headers and macros
RUN printf '%s\n' \
    '#include <stddef.h>' \
    '#include <stdio.h>' \
    '#ifndef _countof' \
    '#define _countof(arr) (sizeof(arr) / sizeof((arr)[0]))' \
    '#endif' \
    '#ifndef sscanf_s' \
    '#define sscanf_s sscanf' \
    '#endif' \
    > /src/msvc_compat.h

# Stage 2a: Compile for RG353V (RK3566 / Cortex-A55)
FROM builder AS rk3566-builder

# Add -fsigned-char and -fno-strict-aliasing to match MSVC's exact data representation and memory-aliasing behavior on ARM
RUN cd turfmastrand && \
    aarch64-linux-gnu-gcc \
        -O2 \
        -fsigned-char \
        -fno-strict-aliasing \
        -march=armv8.2-a \
        -mcpu=cortex-a55 \
        -include /src/msvc_compat.h \
        -I. \
        -I./pcg-c-basic-0.9 \
        turfmastrand.c \
        sha1.c \
        pcg-c-basic-0.9/pcg_basic.c \
        -o /src/turfmastrand/turfmastrand \
        -lm

# Stage 2b: Compile for DE10-Nano (Cyclone V / Cortex-A9)
FROM builder AS mister-builder

# Add -fsigned-char and -fno-strict-aliasing to match MSVC's exact data representation and memory-aliasing behavior on ARM
RUN cd turfmastrand && \
    arm-linux-gnueabihf-gcc \
        -O2 \
        -static \
        -fsigned-char \
        -fno-strict-aliasing \
        -march=armv7-a \
        -mcpu=cortex-a9 \
        -mfpu=neon \
        -mfloat-abi=hard \
        -include /src/msvc_compat.h \
        -I. \
        -I./pcg-c-basic-0.9 \
        turfmastrand.c \
        sha1.c \
        pcg-c-basic-0.9/pcg_basic.c \
        -o /src/turfmastrand/turfmastrand \
        -lm

RUN cd lithogen && \
# Force full static linking through Libtool (-all-static)
    autoreconf -fi && \
    ./configure \
        --host=arm-linux-gnueabihf \
        --disable-shared \
        --enable-static \
        CFLAGS="-O2 -march=armv7-a -mcpu=cortex-a9 -mfpu=neon -mfloat-abi=hard" && \
    make -j"$(nproc)" LDFLAGS="-all-static"

# Stage 2c: Compile for amd64
FROM builder AS amd64-builder

RUN cd turfmastrand && \
    gcc \
        -O2 \
        -static \
        -fsigned-char \
        -fno-strict-aliasing \
        -march=x86-64 \
        -include /src/msvc_compat.h \
        -I. \
        -I./pcg-c-basic-0.9 \
        turfmastrand.c \
        sha1.c \
        pcg-c-basic-0.9/pcg_basic.c \
        -o /src/turfmastrand/turfmastrand \
        -lm

RUN cd lithogen && \
    autoreconf -fi && \
    ./configure \
        --disable-shared \
        --enable-static \
        CFLAGS="-O2 -march=x86-64" && \
    make -j"$(nproc)" LDFLAGS="-all-static"

# Stage 3a: Export only the compiled binaries
FROM scratch AS rk3566-export
COPY --from=rk3566-builder /src/turfmastrand/turfmastrand /turfmastrand

# Stage 3b: Export only the compiled binaries
FROM scratch AS mister-export
COPY --from=mister-builder /src/turfmastrand/turfmastrand /turfmastrand
COPY --from=mister-builder /src/lithogen/lithogen /lithogen

# Stage 3c: Export only the compiled binaries
FROM scratch AS amd64-export
COPY --from=amd64-builder /src/turfmastrand/turfmastrand /turfmastrand
COPY --from=amd64-builder /src/lithogen/lithogen /lithogen