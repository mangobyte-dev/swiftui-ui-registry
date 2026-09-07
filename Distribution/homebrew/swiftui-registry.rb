# Formula template for the mangobyte-dev/homebrew-tap repository, as Formula/swiftui-registry.rb.
# The release workflow uploads swiftui-registry-macos-universal.tar.gz and its .sha256 to the
# GitHub release of the tag; copy that checksum into sha256 below, and tag the tap
# swiftui-registry-<version> so the tool's update notice can see the release.
class SwiftuiRegistry < Formula
  desc "Copy source-owned SwiftUI registry items into your app and keep them updatable"
  homepage "https://github.com/mangobyte-dev/swiftui-ui-registry"
  url "https://github.com/mangobyte-dev/swiftui-ui-registry/releases/download/0.2.0/swiftui-registry-macos-universal.tar.gz"
  version "0.2.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"

  depends_on :macos

  def install
    bin.install "swiftui-registry"
  end

  test do
    assert_match "0.2.0", shell_output("#{bin}/swiftui-registry --version")
  end
end
