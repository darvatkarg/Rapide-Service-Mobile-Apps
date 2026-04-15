// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "webview_flutter_wkwebview", path: "../.packages/webview_flutter_wkwebview"),
        .package(name: "video_player_avfoundation", path: "../.packages/video_player_avfoundation"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios"),
        .package(name: "speech_to_text", path: "../.packages/speech_to_text"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation"),
        .package(name: "path_provider_foundation", path: "../.packages/path_provider_foundation"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios"),
        .package(name: "google_sign_in_ios", path: "../.packages/google_sign_in_ios"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus"),
        .package(name: "geolocator_apple", path: "../.packages/geolocator_apple"),
        .package(name: "geocoding_ios", path: "../.packages/geocoding_ios"),
        .package(name: "stripe_ios", path: "../.packages/stripe_ios"),
        .package(name: "flutter_local_notifications", path: "../.packages/flutter_local_notifications"),
        .package(name: "sqflite_darwin", path: "../.packages/sqflite_darwin"),
        .package(name: "firebase_messaging", path: "../.packages/firebase_messaging"),
        .package(name: "firebase_core", path: "../.packages/firebase_core"),
        .package(name: "firebase_auth", path: "../.packages/firebase_auth"),
        .package(name: "file_picker", path: "../.packages/file_picker"),
        .package(name: "connectivity_plus", path: "../.packages/connectivity_plus")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "webview-flutter-wkwebview", package: "webview_flutter_wkwebview"),
                .product(name: "video-player-avfoundation", package: "video_player_avfoundation"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "speech-to-text", package: "speech_to_text"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "google-sign-in-ios", package: "google_sign_in_ios"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "geolocator-apple", package: "geolocator_apple"),
                .product(name: "geocoding-ios", package: "geocoding_ios"),
                .product(name: "stripe-ios", package: "stripe_ios"),
                .product(name: "flutter-local-notifications", package: "flutter_local_notifications"),
                .product(name: "sqflite-darwin", package: "sqflite_darwin"),
                .product(name: "firebase-messaging", package: "firebase_messaging"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-auth", package: "firebase_auth"),
                .product(name: "file-picker", package: "file_picker"),
                .product(name: "connectivity-plus", package: "connectivity_plus")
            ]
        )
    ]
)
