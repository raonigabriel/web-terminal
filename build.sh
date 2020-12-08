#!/bin/bash
# Build
VERSION=1.0.0
docker buildx build --platform linux/arm/v7 -t raonigabriel/web-terminal:armv7-${VERSION} ./armv7
docker buildx build --platform linux/arm64 -t raonigabriel/web-terminal:arm64-${VERSION} ./arm64
docker buildx build -t raonigabriel/web-terminal:386-${VERSION} ./386
docker buildx build -t raonigabriel/web-terminal:amd64-${VERSION} ./amd64
docker manifest create raonigabriel/web-terminal:${VERSION} raonigabriel/web-terminal:armv7-${VERSION} raonigabriel/web-terminal:arm64-${VERSION} raonigabriel/web-terminal:386-${VERSION} raonigabriel/web-terminal:amd64-${VERSION} 
# Tag  latest version
docker tag raonigabriel/web-terminal:armv7-${VERSION} raonigabriel/web-terminal:armv7-latest
docker tag raonigabriel/web-terminal:arm64-${VERSION} raonigabriel/web-terminal:arm64-latest
docker tag raonigabriel/web-terminal:386-${VERSION} raonigabriel/web-terminal:386-latest
docker tag raonigabriel/web-terminal:amd64-${VERSION} raonigabriel/web-terminal:amd64-latest 
docker manifest create raonigabriel/web-terminal:latest raonigabriel/web-terminal:armv7-latest raonigabriel/web-terminal:arm64-latest raonigabriel/web-terminal:386-latest raonigabriel/web-terminal:amd64-latest
# Push
docker manifest push raonigabriel/web-terminal:${VERSION}
docker manifest push raonigabriel/web-terminal:latest