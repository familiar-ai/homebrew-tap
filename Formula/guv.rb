# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.2.9"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.9/guv_Darwin_arm64.tar.gz"
      sha256 "0d9a316a5776ea1ed8f13a2ce9dae74cd60a869390df85972b32ff7f506359d7"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.9/guv_Darwin_x86_64.tar.gz"
      sha256 "94a266d9c09a45ad63a2783139bf4e50da5f669390f2c073766605ea1d164184"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.9/guv_Linux_arm64.tar.gz"
      sha256 "4b31a2b331a1f39fc839d46893f1ef008bcc506021c7f7c0d1d2c0ab6a4067c9"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.9/guv_Linux_x86_64.tar.gz"
      sha256 "c6648682b0fc17f8a43caca4c1dd535d9095c74a7493d65d1df8df9b2c3a4dc4"
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
      Optional Claude Handler needs logged-in `claude` and foreground `guv-handler-claude start`.
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/guv 2>&1", 2)
    assert_predicate bin/"guv-handler-claude", :executable?
    assert_predicate pkgshare/"sdk/index.ts", :exist?
    assert_predicate pkgshare/"sdk/README.md", :exist?
  end
end
