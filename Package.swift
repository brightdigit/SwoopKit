// swift-tools-version: 6.4

import PackageDescription

// The release-data records shared by SwoopMistKit (writes them to CloudKit),
// SwoopCloudKit (reads them with native CloudKit), Stewed and Bushel.
// Foundation only, so it builds everywhere its consumers do (including Linux).
let package = Package(
  name: "SwoopKit",
  platforms: [
    .macOS(.v12),
    .iOS(.v18),
    .watchOS(.v11),
    .tvOS(.v18),
    .visionOS(.v2),
    .macCatalyst(.v18),
  ],
  products: [
    .library(name: "SwoopKit", targets: ["SwoopKit"])
  ],
  targets: [
    .target(
      name: "SwoopKit",
      swiftSettings: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
      ]
    ),
    .testTarget(
      name: "SwoopKitTests",
      dependencies: ["SwoopKit"],
      swiftSettings: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
