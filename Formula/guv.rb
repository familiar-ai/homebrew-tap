# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.1.1"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.1.1/guv_Darwin_arm64.tar.gz"
      sha256 "217613fac44c80fbed06fc7a1820e130e259e742f51e9c2b22b2cbea2aeb18d5"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.1.1/guv_Darwin_x86_64.tar.gz"
      sha256 "7de1448443d93449e91cbbb9a1aaccca8549795c85c0f474d91d725797961428"
    end
  end

  depends_on "qrencode"

  def install
    guv_binary = File.exist?("bin/guv") ? "bin/guv" : "guv"
    bin.install guv_binary => "guv"
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
