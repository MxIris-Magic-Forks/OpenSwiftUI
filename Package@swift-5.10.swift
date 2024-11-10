// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

func envEnable(_ key: String, default defaultValue: Bool = false) -> Bool {
    guard let value = Context.environment[key] else {
        return defaultValue
    }
    if value == "1" {
        return true
    } else if value == "0" {
        return false
    } else {
        return defaultValue
    }
}

let isXcodeEnv = Context.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode"
let development = envEnable("OPENSWIFTUI_DEVELOPMENT", default: false)

// Xcode use clang as linker which supports "-iframework" while SwiftPM use swiftc as linker which supports "-Fsystem"
let systemFrameworkSearchFlag = isXcodeEnv ? "-iframework" : "-Fsystem"

let releaseVersion = Context.environment["OPENSWIFTUI_TARGET_RELEASE"].flatMap { Int($0) } ?? 2021
let platforms: [SupportedPlatform] = switch releaseVersion {
case 2024:
    #if swift(>=6.0)
    [
        .iOS(.v18),
        .macOS(.v15),
        .macCatalyst(.v18),
        .tvOS(.v18),
        .watchOS(.v10),
        .visionOS(.v2),
    ]
    #else // FIXME: Remove when we bump to Swift 6.0
    [
        .iOS(.v17),
        .macOS(.v14),
        .macCatalyst(.v17),
        .tvOS(.v17),
        .watchOS(.v9),
        .visionOS(.v1),
    ]
    #endif
case 2021: // iOS 15.5
    [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15),
        .tvOS(.v15),
        .watchOS(.v7),
    ]
default:
    [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v7), // WKApplicationMain is available for watchOS 7.0+
        .visionOS(.v1),
    ]
}

var sharedSwiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableExperimentalFeature("AccessLevelOnImport"),
    // .enableUpcomingFeature("InternalImportsByDefault"),
    .define("OPENSWIFTUI_SUPPRESS_DEPRECATED_WARNINGS"),
    .define("OPENSWIFTUI_RELEASE_\(releaseVersion)"),
]

if releaseVersion >= 2021 {
    for year in 2021 ... releaseVersion {
        sharedSwiftSettings.append(.define("OPENSWIFTUI_SUPPORT_\(year)_API"))
    }
}

let warningsAsErrorsCondition = envEnable("OPENSWIFTUI_WERROR", default: isXcodeEnv && development)
if warningsAsErrorsCondition {
    sharedSwiftSettings.append(.unsafeFlags(["-warnings-as-errors"]))
}

let openSwiftUICoreTarget = Target.target(
    name: "OpenSwiftUICore",
    dependencies: [
        "OpenSwiftUI_SPI",
        .product(name: "OpenGraphShims", package: "OpenGraph"),
    ],
    swiftSettings: sharedSwiftSettings
)
let openSwiftUITarget = Target.target(
    name: "OpenSwiftUI",
    dependencies: [
        "OpenSwiftUICore",
        .target(name: "CoreServices", condition: .when(platforms: [.iOS])),
        .product(name: "OpenGraphShims", package: "OpenGraph"),
    ],
    swiftSettings: sharedSwiftSettings
)
let openSwiftUIExtensionTarget = Target.target(
    name: "OpenSwiftUIExtension",
    dependencies: [
        "OpenSwiftUI",
    ],
    swiftSettings: sharedSwiftSettings
)
let openSwiftUICoreTestTarget = Target.testTarget(
    name: "OpenSwiftUICoreTests",
    dependencies: [
        "OpenSwiftUICore",
    ],
    exclude: ["README.md"],
    swiftSettings: sharedSwiftSettings
)
let openSwiftUITestTarget = Target.testTarget(
    name: "OpenSwiftUITests",
    dependencies: [
        "OpenSwiftUI",
    ],
    exclude: ["README.md"],
    swiftSettings: sharedSwiftSettings
)
let openSwiftUICompatibilityTestTarget = Target.testTarget(
    name: "OpenSwiftUICompatibilityTests",
    exclude: ["README.md"],
    swiftSettings: sharedSwiftSettings
)

let swiftBinPath = Context.environment["_"] ?? "/usr/bin/swift"
let swiftBinURL = URL(fileURLWithPath: swiftBinPath)
let SDKPath = swiftBinURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().path
let includePath = SDKPath.appending("/usr/lib/swift")

let package = Package(
    name: "OpenSwiftUI",
    platforms: platforms,
    products: [
        .library(name: "OpenSwiftUI", targets: ["OpenSwiftUI", "OpenSwiftUIExtension"]),
        // FIXME: This will block xcodebuild build(iOS CI) somehow
        // .library(name: "OpenSwiftUI_SPI", targets: ["OpenSwiftUI_SPI"]),
    ],
    targets: [
        // TODO: Add SwiftGTK as an backend alternative for UIKit/AppKit on Linux and macOS
        .systemLibrary(
            name: "CGTK",
            pkgConfig: "gtk4",
            providers: [
                .brew(["gtk4"]),
                .apt(["libgtk-4-dev clang"]),
            ]
        ),
        .target(
            name: "OpenSwiftUI_SPI",
            publicHeadersPath: ".",
            cSettings: [
                .unsafeFlags(["-I", includePath], .when(platforms: .nonDarwinPlatforms)),
                .define("__COREFOUNDATION_FORSWIFTFOUNDATIONONLY__", to: "1", .when(platforms: .nonDarwinPlatforms)),
                .define("_WASI_EMULATED_SIGNAL", .when(platforms: [.wasi])),
            ]
        ),
        .binaryTarget(name: "CoreServices", path: "PrivateFrameworks/CoreServices.xcframework"),
        openSwiftUICoreTarget,
        openSwiftUITarget,
        openSwiftUIExtensionTarget,
    ]
)

#if os(macOS)
let attributeGraphCondition = envEnable("OPENGRAPH_ATTRIBUTEGRAPH", default: true)
#else
let attributeGraphCondition = envEnable("OPENGRAPH_ATTRIBUTEGRAPH")
#endif

extension Target {
    func addAGSettings() {
        // FIXME: Weird SwiftPM behavior for test Target. Otherwize we'll get the following error message
        // "could not determine executable path for bundle 'AttributeGraph.framework'"
        dependencies.append(.product(name: "AttributeGraph", package: "OpenGraph"))
        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENGRAPH_ATTRIBUTEGRAPH"))
        self.swiftSettings = swiftSettings
    }

    func addOpenCombineSettings() {
        dependencies.append(.product(name: "OpenCombine", package: "OpenCombine"))
        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENSWIFTUI_OPENCOMBINE"))
        self.swiftSettings = swiftSettings
    }

    func addSwiftLogSettings() {
        dependencies.append(.product(name: "Logging", package: "swift-log"))
        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENSWIFTUI_SWIFT_LOG"))
        self.swiftSettings = swiftSettings
    }

    func addSwiftCryptoSettings() {
        dependencies.append(.product(name: "Crypto", package: "swift-crypto"))
        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENSWIFTUI_SWIFT_CRYPTO"))
        self.swiftSettings = swiftSettings
    }
    
    func addSwiftTestingSettings() {
        dependencies.append(.product(name: "Testing", package: "swift-testing"))
        var swiftSettings = swiftSettings ?? []
        swiftSettings.append(.define("OPENSWIFTUI_SWIFT_TESTING"))
        self.swiftSettings = swiftSettings
    }
}

if attributeGraphCondition {
    openSwiftUICoreTarget.addAGSettings()
    openSwiftUITarget.addAGSettings()
    openSwiftUICoreTestTarget.addAGSettings()
    openSwiftUITestTarget.addAGSettings()
    openSwiftUICompatibilityTestTarget.addAGSettings()
}

#if os(macOS)
let openCombineCondition = envEnable("OPENSWIFTUI_OPENCOMBINE")
#else
let openCombineCondition = envEnable("OPENSWIFTUI_OPENCOMBINE", default: true)
#endif
if openCombineCondition {
    package.dependencies.append(
        .package(url: "https://github.com/OpenSwiftUIProject/OpenCombine.git", from: "0.15.0")
    )
    openSwiftUICoreTarget.addOpenCombineSettings()
    openSwiftUITarget.addOpenCombineSettings()
}

#if os(macOS)
let swiftLogCondition = envEnable("OPENSWIFTUI_SWIFT_LOG")
#else
let swiftLogCondition = envEnable("OPENSWIFTUI_SWIFT_LOG", default: true)
#endif
if swiftLogCondition {
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-log", from: "1.5.3")
    )
    openSwiftUICoreTarget.addSwiftLogSettings()
    openSwiftUITarget.addSwiftLogSettings()
}

#if os(macOS)
let swiftCryptoCondition = envEnable("OPENSWIFTUI_SWIFT_CRYPTO")
#else
let swiftCryptoCondition = envEnable("OPENSWIFTUI_SWIFT_CRYPTO", default: true)
#endif
if swiftCryptoCondition {
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.8.0")
    )
    openSwiftUICoreTarget.addSwiftCryptoSettings()
    openSwiftUITarget.addSwiftCryptoSettings()
}

// Remove the check when swift-testing reaches 1.0.0
let swiftTestingCondition = envEnable("OPENSWIFTUI_SWIFT_TESTING")
if swiftTestingCondition {
    package.dependencies.append(
        // Fix it to be 0.3.0 before we bump to Swift 5.10
        .package(url: "https://github.com/apple/swift-testing", exact: "0.6.0")
    )
    openSwiftUICoreTestTarget.addSwiftTestingSettings()
    openSwiftUITestTarget.addSwiftTestingSettings()
    openSwiftUICompatibilityTestTarget.addSwiftTestingSettings()

    package.targets.append(openSwiftUICoreTestTarget)
    package.targets.append(openSwiftUITestTarget)
    package.targets.append(openSwiftUICompatibilityTestTarget)
}

let compatibilityTestCondition = envEnable("OPENSWIFTUI_COMPATIBILITY_TEST")
if compatibilityTestCondition {
    var swiftSettings: [SwiftSetting] = (openSwiftUICompatibilityTestTarget.swiftSettings ?? [])
    swiftSettings.append(.define("OPENSWIFTUI_COMPATIBILITY_TEST"))
    openSwiftUICompatibilityTestTarget.swiftSettings = swiftSettings
} else {
    openSwiftUICompatibilityTestTarget.dependencies.append("OpenSwiftUI")
}

let useLocalDeps = envEnable("OPENSWIFTUI_USE_LOCAL_DEPS")
if useLocalDeps {
    package.dependencies += [
        .package(path: "../OpenGraph"),
    ]
} else {
    package.dependencies += [
        // FIXME: on Linux platform: OG contains unsafe build flags which prevents us using version dependency
        .package(url: "https://github.com/OpenSwiftUIProject/OpenGraph", branch: "main"),
    ]
}

extension [Platform] {
    static var nonDarwinPlatforms: [Platform] {
        [.linux, .android, .wasi, .openbsd, .windows]
    }
}
