# Stage 1: Build the Flutter web application
FROM ghcr.io/cirruslabs/flutter:stable AS build

ARG APP_VERSION
ENV APP_VERSION=$APP_VERSION

WORKDIR /app

COPY pubspec.yaml ./
RUN flutter pub get

COPY . .

RUN flutter --version
RUN flutter build web --release --pwa-strategy=offline-first

# Activate and run the Service Worker generator with better caching strategy
RUN dart pub global activate sw
RUN dart run sw:generate \
    --input=build/web \
    --output=flutter_service_worker.js \
    --prefix=pwacam-cache \
    --version=$APP_VERSION \
    --strategy=offline-first \
    --no-versioned-files \
    --glob="**.{html,js,wasm,json,css}; assets/**; canvaskit/**; icons/**; manifest.json" \
    --no-glob="flutter_service_worker.js; **/*.map; assets/NOTICES; favicon.png"

# Replace version placeholders in all HTML and JS files
RUN find build/web -name "*.html" -exec sed -i 's/__VERSION__/'$APP_VERSION'/g' {} \;
RUN find build/web -name "*.js" -exec sed -i 's/__VERSION__/'$APP_VERSION'/g' {} \;
RUN find build/web -name "flutter_service_worker.js" -exec sed -i 's/__VERSION__/'$APP_VERSION'/g' {} \;

# Add version info to manifest.json
RUN sed -i 's/"version": "1.0.3"/"version": "1.0.3-'$APP_VERSION'"/g' build/web/manifest.json

# Create version file for debugging
RUN echo "Build Version: $APP_VERSION\nBuild Date: $(date)" > build/web/version.txt

# Stage 2: Serve the built application with Nginx
FROM nginx:alpine

# Install gettext for envsubst (for environment variable substitution)
RUN apk add --no-cache gettext

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built application
COPY --from=build /app/build/web /usr/share/nginx/html

# Create a startup script to handle environment variables
RUN echo '#!/bin/sh\n\
envsubst "\$FLUTTER_BASE_HREF" < /usr/share/nginx/html/index.html > /usr/share/nginx/html/index_substituted.html\n\
mv /usr/share/nginx/html/index_substituted.html /usr/share/nginx/html/index.html\n\
exec nginx -g "daemon off;"' > /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]