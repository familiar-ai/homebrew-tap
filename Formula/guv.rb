# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.2.2"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.2/guv_Darwin_arm64.tar.gz"
      sha256 "e95d3e91df669f123de7e619e2f72a831e1e11d21eafa83085224178e2a4cdf3"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.2/guv_Darwin_x86_64.tar.gz"
      sha256 "38ce18747925c7c6967368874fc58470c8f5d786ac7f93b4dc3127a3685ab0f7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.2/guv_Linux_arm64.tar.gz"
      sha256 "c0e3949a9495526e8030f4f81f0695a2e7a53b1be9c96e3fc4f8ddbb13f6d8db"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.2/guv_Linux_x86_64.tar.gz"
      sha256 "bd74ee1b61354a8687cdd1c5a651ecde3a681488617ed9a12ab5f9832f4b6a13"
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
