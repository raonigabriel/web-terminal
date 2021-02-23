#!/bin/bash
# Build semantic-version
VERSION=1.0.1
docker buildx build --no-cache --platform linux/arm/v7 -t raonigabriel/web-terminal:armv7-${VERSION} ./armv7
docker buildx build --no-cache --platform linux/arm64 -t raonigabriel/web-terminal:arm64-${VERSION} ./arm64
docker buildx build --no-cache --platform linux/386 -t raonigabriel/web-terminal:386-${VERSION} ./386
docker buildx build --no-cache --platform linux/amd64 -t raonigabriel/web-terminal:amd64-${VERSION} ./amd64
# Push semantic-version
docker push raonigabriel/web-terminal:armv7-${VERSION}
docker push raonigabriel/web-terminal:arm64-${VERSION}
docker push raonigabriel/web-terminal:386-${VERSION}
docker push raonigabriel/web-terminal:amd64-${VERSION}
# Manifest for semantic-version
docker manifest create raonigabriel/web-terminal:${VERSION} raonigabriel/web-terminal:armv7-${VERSION} raonigabriel/web-terminal:arm64-${VERSION} raonigabriel/web-terminal:386-${VERSION} raonigabriel/web-terminal:amd64-${VERSION} 
docker manifest inspect raonigabriel/web-terminal:${VERSION}
docker manifest push -p raonigabriel/web-terminal:${VERSION}
# Tag to latest-version
docker tag raonigabriel/web-terminal:armv7-${VERSION} raonigabriel/web-terminal:armv7-latest
docker tag raonigabriel/web-terminal:arm64-${VERSION} raonigabriel/web-terminal:arm64-latest
docker tag raonigabriel/web-terminal:386-${VERSION} raonigabriel/web-terminal:386-latest
docker tag raonigabriel/web-terminal:amd64-${VERSION} raonigabriel/web-terminal:amd64-latest 
# Push latest-version
docker push raonigabriel/web-terminal:armv7-latest
docker push raonigabriel/web-terminal:arm64-latest
docker push raonigabriel/web-terminal:386-latest
docker push raonigabriel/web-terminal:amd64-latest
# Manifest for latest-version
docker manifest create raonigabriel/web-terminal:latest raonigabriel/web-terminal:armv7-latest raonigabriel/web-terminal:arm64-latest raonigabriel/web-terminal:386-latest raonigabriel/web-terminal:amd64-latest
docker manifest inspect raonigabriel/web-terminal:latest
docker manifest push -p raonigabriel/web-terminal:latest