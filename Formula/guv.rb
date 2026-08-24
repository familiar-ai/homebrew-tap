# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.3.1"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.1/guv_Darwin_arm64.tar.gz"
      sha256 "73fff1a27466bbcb1faf12541883f361bea790721ba844727182a2473ec1bfec"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.1/guv_Darwin_x86_64.tar.gz"
      sha256 "214e00fd3550354f3fb0f8df19a40d97e4425f1f5a26d673d729d699afd97ee2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.1/guv_Linux_arm64.tar.gz"
      sha256 "715f48eaad9ea8592a520be60d107f65d54109d4a4026a5fdab7ee9ac5717192"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.1/guv_Linux_x86_64.tar.gz"
      sha256 "9650278ec1a62da8e0f9db0145ce71e5ea7e93dd1eaf9363b26da7e0242b2745"
    end
  end

  def install
    guv_binary = File.exist?("bin/guv") ? "bin/guv" : "guv"
    bin.install guv_binary => "guv"
    bin.install "bin/guv-handler-claude"
    pkgshare.install "share/guv/sdk" if File.directory?("share/guv/sdk")
    pkgshare.install "share/guv/handlers" if File.directory?("share/guv/handlers")
    pkgshare.install "share/guv/skills" if File.directory?("share/guv/skills")
  end

  service do
    run [opt_bin/"guv", "run"]
    keep_alive true
    environment_variables PATH: [
      File.join(Dir.home, ".local", "bin"),
      File.join(Dir.home, ".bun", "bin"),
      std_service_path_env,
    ].join(File::PATH_SEPARATOR)
    log_path var/"log/guv.log"
    error_log_path var/"log/guv.log"
  end

  def caveats
    <<~EOS
      Pair and configure Guv:
        guv setup

      Setup detects installed Pi and Claude Code Handlers, shows the App QR,
      configures the selected Handler, starts Guv, and runs checks.
      Foreground demo: stop the service, then run `guv run --show-handler`.
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/guv 2>&1", 2)
    assert_predicate bin/"guv-handler-claude", :executable?
    assert_predicate pkgshare/"sdk/index.ts", :exist?
    assert_predicate pkgshare/"sdk/README.md", :exist?
    assert_predicate pkgshare/"handlers/pi/setup.json", :exist?
    assert_predicate pkgshare/"handlers/claude/setup.json", :exist?
    assert_predicate pkgshare/"skills/guv-support/SKILL.md", :exist?
  end
end
