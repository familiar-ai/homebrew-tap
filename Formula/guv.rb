# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.3.43"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.43/guv_Darwin_arm64.tar.gz"
      sha256 "ae6fb91a6d950876b5d8cb6b3dabd770d3d7337ed2ade14ee6f64c2e601aadc6"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.43/guv_Darwin_x86_64.tar.gz"
      sha256 "9271c85e1a734cdf9157f3a7ae515f550aeb0fa18042043fd91905ea99906ea3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.43/guv_Linux_arm64.tar.gz"
      sha256 "384ffefa15a2af22cc00d50f773dbf0aac98f9e566288876e80a6baabcc93893"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.43/guv_Linux_x86_64.tar.gz"
      sha256 "86cb3e18d052ca76e65291ff279ffc5d7ec9c2acb14b26d7bc4f1d8ce7416827"
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
    assert_predicate pkgshare/"sdk/node_modules/zod/package.json", :exist?
    assert_equal({ "zod" => "file:./node_modules/zod" }, JSON.parse((pkgshare/"sdk/package.json").read)["dependencies"])
    assert_predicate pkgshare/"handlers/pi/setup.json", :exist?
    assert_predicate pkgshare/"handlers/claude/setup.json", :exist?
    assert_predicate pkgshare/"skills/guv-support/SKILL.md", :exist?
  end
end
