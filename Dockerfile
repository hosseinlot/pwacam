# Stage 1: Build the Flutter web application
FROM ghcr.io/cirruslabs/flutter:stable AS build

ARG APP_VERSION

WORKDIR /app

COPY pubspec.yaml ./
RUN flutter pub get

COPY . .

RUN flutter build web --release

# Activate and run the Service Worker generator
RUN dart pub global activate sw
RUN dart run sw:generate \
    --input=build/web \
    --output=flutter_service_worker.js \
    --prefix=pwacam-cache \
    --glob="**.{html,js,wasm,json}" \
    --no-glob="flutter_service_worker.js; **/*.map; assets/NOTICES"

RUN sed -i 's/__VERSION__/'$APP_VERSION'/g' build/web/index.html

# Stage 2: Serve the built application with Nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80