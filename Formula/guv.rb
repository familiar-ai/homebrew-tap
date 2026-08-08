# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.2.16"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.16/guv_Darwin_arm64.tar.gz"
      sha256 "7b14f68581884f6d573d2f0c4d5e7db2cdfe43bc23fc507a32166ce42c904b6d"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.16/guv_Darwin_x86_64.tar.gz"
      sha256 "594ed24abd2ad9f899b9303b6de920a49e1dce80f655cf1cb0f89678ee03b983"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.16/guv_Linux_arm64.tar.gz"
      sha256 "c7e870663a57b06b33185af43f9e570ece4e9d6117fce2fb3a7a0e827ed42e3a"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.16/guv_Linux_x86_64.tar.gz"
      sha256 "dbcf413332cf0e8317d7a758a58f3fd60110ee6042858709dd6d5617299f42db"
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
        guv up          # prompts for your Setup Token, shows the QR

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
