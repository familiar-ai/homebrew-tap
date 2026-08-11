# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.2.18"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.18/guv_Darwin_arm64.tar.gz"
      sha256 "410cde335f8c423cfaa19a3fa4e17410a262d6ae0cd42b310043775e12b681af"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.18/guv_Darwin_x86_64.tar.gz"
      sha256 "fcd4921a4570d116cb8c406f48de7ec13bb2c88fc765546f6b9bfd8bbe63639c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.18/guv_Linux_arm64.tar.gz"
      sha256 "6318fb7efd681b59ff1542d5bc37820474e22aceab20974f0a762d60fb38e31d"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.18/guv_Linux_x86_64.tar.gz"
      sha256 "8daf06dfb19235f94368f05f77d29982062eee2d04e37b3ef96cfe367c050adc"
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
