# Formula template for familiar-ai/homebrew-tap.
# Release CI in adstastic/v1 replaces version, URLs, and sha256 values.
# Installs release artifacts only; never clones adstastic/v1.
class Guv < Formula
  desc "Guv daemon + CLI: durable Job/Effect engine for the app"
  homepage "https://github.com/familiar-ai/homebrew-tap"
  version "0.2.13"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.13/guv_Darwin_arm64.tar.gz"
      sha256 "a74be56373c137a8742f1b60fdeb453c696d706bb3320712c9077697a0d709de"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.13/guv_Darwin_x86_64.tar.gz"
      sha256 "54c2838db2780d85e2f7374e2d7a8295a4bb65199fd91aff06417124e4cdc0be"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.13/guv_Linux_arm64.tar.gz"
      sha256 "ce9b835e9e7f95999b76e6a84accc5a9ad61d7ed3bd7dc6a055713910c611ef9"
    end

    on_intel do
      url "https://github.com/familiar-ai/homebrew-tap/releases/download/guv-v0.2.13/guv_Linux_x86_64.tar.gz"
      sha256 "cd4cae94d44b18e5c39af10416d66908ddac05b8a16b9c5393dc5d61db6df90f"
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
