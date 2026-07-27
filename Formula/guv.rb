# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.2.12"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.12/guv_Darwin_arm64.tar.gz"
      sha256 "a34cd73af4d9633e7599abfe5c450baf1e946477a96574a7891dacab2d6834ce"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.12/guv_Darwin_x86_64.tar.gz"
      sha256 "db916c2f04595947463fe4a51fe9a82f08814f000c0c4a57af039ab7f320eb63"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.12/guv_Linux_arm64.tar.gz"
      sha256 "61d04e27cf65bd3004d96c831ad21e071109f8a79c10703130b18e00e6bdaa4e"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.12/guv_Linux_x86_64.tar.gz"
      sha256 "0356f47365111397054e9dc96a2f880750e498f340d302601a55f3a1f6a6f275"
    end
  end

  depends_on "qrencode"

  def install
    guv_binary = File.exist?("bin/guv") ? "bin/guv" : "guv"
    bin.install guv_binary => "guv"
    bin.install "bin/guv-handler-claude"
    bin.install_symlink bin/"guv" => "guvd"
    pkgshare.install "share/guv/sdk" if File.directory?("share/guv/sdk")
  end

  service do
    run opt_bin/"guvd"
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
      Pair this machine and your phone:
        brew services start guv
        guv up          # prompts for your invite code, shows the QR

      Then: guv status · guv logs
      Default Handler needs logged-in `pi`.
      Optional Claude Handler needs logged-in `claude`; Guv starts it after Handler selection.
      Foreground demo: stop the service, then run `guv run --show-handler`.
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/guv 2>&1", 2)
    assert_predicate bin/"guv-handler-claude", :executable?
    assert_predicate pkgshare/"sdk/index.ts", :exist?
    assert_predicate pkgshare/"sdk/README.md", :exist?
  end
end
