# CI runner images (as of 2026-11-25)

- Swift 6.4 is released; Linux lanes use `swift:6.4-<os>` (6.4.3 at the time). The `swiftlang/swift:nightly-6.4.x` images are no longer needed.
- `runs-on: xcode-27` is a preview image with Xcode 27.0, 27.1 (default) and 27.2. Pin `/Applications/Xcode_27.2.app` (a symlink that survives image refreshes) and 27.2 simulators. 27.2 renamed the devices: `iPhone 18 Pro`, `Apple Watch Ultra 4 (49mm)`, `Apple TV 4K (4th generation)`; `Apple Vision Pro` is unchanged. A wrong device name fails the simulator boot.
- `ubuntu-latest` is Ubuntu 26.04, which lacks `libxml2.so.2`, so the mise-installed SwiftLint binary can't start. Pin non-container jobs that run SwiftLint to `ubuntu-24.04`.
- These mirror MistKit's `mistico` branch (commits a1812e3, 9f5e11b); keep the two repos in step when either moves.
