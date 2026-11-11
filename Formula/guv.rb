# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.3.42"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.42/guv_Darwin_arm64.tar.gz"
      sha256 "0b5dd2a3d1c68b72c6f28fb06b9ec95d49a8a6378960addeafd895a36769e13d"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.42/guv_Darwin_x86_64.tar.gz"
      sha256 "963a233a3b5dc3f8435857e7196b7424bed9cff4ca91aaf2423aa0b159958bc7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.42/guv_Linux_arm64.tar.gz"
      sha256 "77367e7d7972e0a98113c73cdbbe5d3eba00cc6f8e9ba2b8aad5bcb5f8e68f27"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.3.42/guv_Linux_x86_64.tar.gz"
      sha256 "d63fdcfbd69d01cdd4e252b816c45ec2fe2ccdfdf8e50b66d0f39e86e51128d3"
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
