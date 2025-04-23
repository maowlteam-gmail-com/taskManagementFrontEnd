# ----------- Stage 1: Build the Flutter Web App ------------
FROM debian:bullseye-slim AS build

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl unzip xz-utils git ca-certificates bash \
    libc6-dev \
    libstdc++6 \
    libgcc1 \
    && apt-get clean

# Install Flutter SDK
ENV FLUTTER_VERSION=3.29.0-stable
RUN curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz && \
    tar xf flutter_linux_${FLUTTER_VERSION}.tar.xz -C /opt && \
    rm flutter_linux_${FLUTTER_VERSION}.tar.xz

# Set absolute paths for Flutter and Dart
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Fix Git repository ownership issue
RUN git config --global --add safe.directory /opt/flutter

# Set working directory and prepare app
WORKDIR /app

# Copy pubspec files and download dependencies first (layer caching)
COPY pubspec.* ./

# Download dependencies
RUN flutter pub get

# Copy the rest of the app
COPY . .

# Build the release version for web
RUN flutter build web --release

# ----------- Stage 2: Serve using Nginx ------------
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy built web files from previous stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose the port
EXPOSE 80

# Start nginx server
CMD ["nginx", "-g", "daemon off;"]
