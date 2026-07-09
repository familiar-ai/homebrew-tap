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
      sha256 "0c7e4c919829c64863b722abce559a42a4e5c713e8b2720b798b82f2bfb85313"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.1.0/guv_Darwin_x86_64.tar.gz"
      sha256 "101995ad25e88124a5d2ce1541ea13efbd0ad16dc1c41bcc81551e668fe29717"
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
