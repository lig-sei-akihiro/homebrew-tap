cask "claude-usage-bar" do
  version "0.2.1"
  sha256 "1a55aac7fe5c843d02cde2d746c259d699240aefab6e644ac7e22cac9f3764f2"

  url "https://github.com/lig-sei-akihiro/claude-usage-bar/releases/download/v#{version}/ClaudeUsageBar-#{version}.zip",
      verified: "github.com/lig-sei-akihiro/claude-usage-bar/"
  name "Claude Usage Bar"
  desc "Menu bar app showing Claude Code usage across accounts"
  homepage "https://github.com/lig-sei-akihiro/claude-usage-bar"

  depends_on :macos

  app "ClaudeUsageBar.app"

  # The app is only ad-hoc signed (no Developer ID / notarization), so the
  # quarantine flag Homebrew adds on download would make Gatekeeper block it.
  # Strip it here so `brew install --cask claude-usage-bar` just works.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/ClaudeUsageBar.app"]
  end

  uninstall quit: "com.lig-sei-akihiro.claude-usage-bar"

  zap trash: "~/Library/Preferences/com.lig-sei-akihiro.claude-usage-bar.plist"
end
