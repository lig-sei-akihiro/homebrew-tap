cask "claude-usage-bar" do
  version "0.1.0"
  sha256 "c1d9abcc24efbcd81645c37e87e39d8f95a8c7cd41f1f2b5ea0dd4cca2c1e1f1" # `shasum -a 256 dist/ClaudeUsageBar-<version>.zip`

  # Private release asset. Resolve it through the GitHub API and authenticate
  # with Homebrew's built-in credential helper (keychain / `gh` CLI /
  # HOMEBREW_GITHUB_API_TOKEN — whichever the consumer already has). Downloading
  # a private release asset by its browser URL does not work; the API asset URL
  # with an octet-stream Accept header does.
  # `url do` blocks are deprecated in current Homebrew (no replacement), so compute
  # the API asset URL in a method and pass it to a static `url`. Authenticate with
  # Homebrew's built-in credential helper (keychain / gh / HOMEBREW_GITHUB_API_TOKEN).
  # The API asset URL + "Accept: application/octet-stream" is required — a private
  # release asset's browser download URL does not work.
  def asset_url
    assets = GitHub.get_release("lig-sei-akihiro", "claude-usage-bar", "v#{version}").fetch("assets")
    asset  = assets.find { |a| a["name"] == "ClaudeUsageBar-#{version}.zip" }
    odie "release asset ClaudeUsageBar-#{version}.zip not found" unless asset
    asset.fetch("url")
  end

  url asset_url,
      header: [
        "Accept: application/octet-stream",
        "Authorization: bearer #{GitHub::API.credentials}",
      ]
  name "Claude Usage Bar"
  desc "Menu bar app showing Claude Code usage across accounts"
  homepage "https://github.com/lig-sei-akihiro/claude-usage-bar"

  # No `depends_on macos:` — the app's Info.plist (LSMinimumSystemVersion 14.0)
  # enforces the minimum at launch, and the symbol/comparison forms are brittle on
  # brand-new macOS releases.

  app "ClaudeUsageBar.app"

  # The app is only ad-hoc signed (no Developer ID / notarization), so the
  # quarantine flag Homebrew adds on download would make Gatekeeper block it.
  # Strip it here so `brew install --cask claude-usage-bar` just works —
  # no per-user `--no-quarantine` needed.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/ClaudeUsageBar.app"]
  end

  uninstall quit: "com.lig-sei-akihiro.claude-usage-bar"

  zap trash: "~/Library/Preferences/com.lig-sei-akihiro.claude-usage-bar.plist"
end
