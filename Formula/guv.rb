# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.3.16"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.16/guv_Darwin_arm64.tar.gz"
      sha256 "e8a42178153eeeb10aa1d25df7d02a7b90064016a9a3d1479abcfdc406b1b538"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.16/guv_Darwin_x86_64.tar.gz"
      sha256 "293da057cce67def76be14e2ab2cc092b084ebd047c274c6ebf92f03a2c26259"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.16/guv_Linux_arm64.tar.gz"
      sha256 "464abcee8f5433c1db47b91287797b5cbd7a626b0bc5a263e467e7d6f3a7a843"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.16/guv_Linux_x86_64.tar.gz"
      sha256 "cad1759b98e42b6058ac9daec7bc53b504c2b1fa7921895d9937c68cd8ab0d38"
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
