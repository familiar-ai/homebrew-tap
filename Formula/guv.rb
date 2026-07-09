# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.2.0"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.0/guv_Darwin_arm64.tar.gz"
      sha256 "275584dc89cfaec89fa825ecac73118529509d7ac25e7a75345122890fc4664a"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.0/guv_Darwin_x86_64.tar.gz"
      sha256 "cad7153237b3120ef3a5807308935df862a4d54f7a27a3d6b532b0b93a51f1f0"
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
