# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.1.0"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.1.0/guv_Darwin_arm64.tar.gz"
      sha256 "0cbfe84b7d26cba64dc0745ca30020a05fa7ccd2701ad7bb7f71125fd0f54ace"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.1.0/guv_Darwin_x86_64.tar.gz"
      sha256 "5433d194192afb35f4b76cba3e3a6891934a765f9cac6e5f8f31151ea0088488"
    end
  end

  depends_on "qrencode"

  def install
    bin.install "bin/guv" => "guv"
    bin.install_symlink bin/"guv" => "guvd"
    pkgshare.install "share/guv" if File.directory?("share/guv")
  end

  service do
    run opt_bin/"guvd"
    keep_alive true
    environment_variables PATH: std_service_path_env
    log_path var/"log/guv.log"
    error_log_path var/"log/guv.log"
  end

  def caveats
    <<~EOS
      Pair this machine and your phone:
        brew services start guv
        guv up          # prompts for your invite code, shows the QR

      Then: guv status · guv logs
      The handler needs the `pi` CLI installed and logged in.
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/guv 2>&1", 2)
  end
end
