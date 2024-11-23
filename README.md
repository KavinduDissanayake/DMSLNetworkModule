
# DMSLSwiftPackages

## Overview
The `DMSLNetworkModule` is part of the larger **DMSLSwiftPackages** ecosystem, which follows a mono architecture pattern. This structure provides modularity, making it easy to maintain, scale, and test individual components like networking, analytics, and more.

This specific package focuses on providing networking functionalities like API calls, request handling, response parsing, and error management. It's built using Swift and integrates seamlessly into the overall architecture of DMSL.

## Table of Contents
1. [Features](#features)
2. [Installation](#installation)
3. [Usage](https://pickme.atlassian.net/wiki/pages/resumedraft.action?draftId=3448143995)
4. [Modules](#modules)
   - [Analytics](#analytics)
   - [Networking](https://pickme.atlassian.net/wiki/x/e4CGzQ)
   - [Localization](https://pickme.atlassian.net/l/cp/F7pFM0hU)
5. [Resources](#resources)

---

## Features
- **Network Module** supports integration with **Alamofire** for making network requests and handling HTTP responses.
- **Analytics Module** supports integration with **CleverTap** for tracking user events, app performance, and custom analytics.
- Each module can be installed individually depending on your project needs.

## Installation

You can choose which modules (targets) to include in your project using **Swift Package Manager**.

1. Open your project in Xcode.
2. Go to `File > Swift Packages > Add Package Dependency`.
3. Enter the repository URL for your package (e.g., `https://git.mytaxi.lk/in-house-swift-packages/dmslswiftpackages`).
4. Choose the version or branch you want to use.
5. Xcode will show a list of products (modules) that you can choose from:
    - `NetworkModule`: Includes Alamofire for making network requests.
    - `AnalyticsModule`: Includes CleverTapSDK for tracking analytics.

6. Select the module(s) you need based on your project requirements.

Alternatively, if you're using the **Swift Package Manager** directly in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://git.mytaxi.lk/in-house-swift-packages/dmslswiftpackages", .upToNextMajor(from: "0.0.2"))
]
