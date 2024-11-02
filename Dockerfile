FROM alpine:latest as libavif-builder

# Set version and commit numbers as environment variables
ENV LIBAOM_VERSION=3.9.1
ENV LIBAVIF_VERSION=1.1.1

# Install required packages
RUN apk update && \
    apk add --no-cache \
    wget \
    ninja \
    yasm \
    pandoc \
    cmake \
    libpng-dev \
    jpeg-dev \
    build-base \
    perl

# <---------------- libaom ------------------->
RUN wget https://storage.googleapis.com/aom-releases/libaom-$LIBAOM_VERSION.tar.gz && \
    tar xzf libaom-$LIBAOM_VERSION.tar.gz && \
    mkdir libaom-$LIBAOM_VERSION/aom-build && \
    cd libaom-$LIBAOM_VERSION/aom-build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=1 \
    -DENABLE_DOCS=no \
    -G Ninja .. && \
    ninja && \
    ninja install && \
    cd ../.. && \
    rm -rf libaom-$LIBAOM_VERSION*
# <---------------- libaom ------------------->

# <---------------- libavif ------------------->
RUN wget -O libavif-$LIBAVIF_VERSION.tar.gz https://github.com/AOMediaCodec/libavif/archive/refs/tags/v$LIBAVIF_VERSION.tar.gz && \
    tar xzf libavif-$LIBAVIF_VERSION.tar.gz && \
    mkdir libavif-$LIBAVIF_VERSION/build && \
    cd libavif-$LIBAVIF_VERSION/build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DAVIF_CODEC_AOM=ON \
    -DAVIF_BUILD_GDK_PIXBUF=ON \
    -DAVIF_BUILD_MAN_PAGES=ON \
    -DLIBYUV_INCLUDE_DIR=/usr/include \
    -DLIBYUV_LIBRARY=/usr/lib/libyuv.so \
    -DAVIF_BUILD_APPS=ON \
    -G Ninja .. && \
    ninja && \
    ninja install && \
    cd ../.. && \
    rm -rf libavif-$LIBAVIF_VERSION*
# <---------------- libavif ------------------->

FROM alpine:latest

# Set the working directory
WORKDIR /workdir

# Install only the required runtime dependencies
RUN apk update && \
    apk add --no-cache \
    libpng \
    jpeg

# Copy the built libraries from the builder stage
COPY --from=libavif-builder /usr/lib/libaom.so* /usr/lib/
COPY --from=libavif-builder /usr/lib/libavif.so* /usr/lib/
COPY --from=libavif-builder /usr/include/avif /usr/include/avif
COPY --from=libavif-builder /usr/include/aom /usr/include/aom
COPY --from=libavif-builder /usr/bin/avifenc /usr/bin/avifenc


CMD ["sh"]

LABEL org.opencontainers.image.source https://github.com/gabileibo/libavif-alpine
