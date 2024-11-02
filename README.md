# libavif-alpine

This repository contains a super lightweight Dockerfile for building [libavif](https://github.com/AOMediaCodec/libavif) on Alpine Linux.

Can be used as a base image for other projects that need to use `avifenc` like an image processing pipeline.

## Usage

### MacOS

```bash
alias avifenc='docker run -it --rm -v "${PWD}:/workdir" ghcr.io/gabileibo/libavif-alpine avifenc'
avifenc --help
```

## Disclaimer

This project, `gabileibo/libavif-alpine`, is an independent project and is in no way associated with, endorsed by, or affiliated with the official `AOMediaCodec/libavif` project or its maintainers. All trademarks and registered trademarks are the property of their respective owners.
