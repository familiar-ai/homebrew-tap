# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.2.14"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.14/guv_Darwin_arm64.tar.gz"
      sha256 "ee2001cfeddf7a3843b6edfd3ec0171d131d80f7c1a7e9c95082149e759264e8"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.14/guv_Darwin_x86_64.tar.gz"
      sha256 "d499f81690bfe50d8a94409d3c239488e58f839b211245f449752bae6a973b7f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.14/guv_Linux_arm64.tar.gz"
      sha256 "4e4bea9640b025873c744b9ca4417b23dba0bda1e3260222a6eddf1668310cfb"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.14/guv_Linux_x86_64.tar.gz"
      sha256 "ce95f6a2b85b4d317ab63f46719cf6b960417751551421d4fc3ed1bd8cca917f"
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
