# frozen_string_literal: true
require 'rubygems/test_case'
require 'rubygems/ext'

class TestGemExtCargoBuilder < Gem::TestCase

  def setup
    @orig_env = ENV.to_hash

    @rust_envs = {
      'RUSTUP_HOME' => File.join(File.expand_path('~'), '.rustup'),
      'CARGO_HOME' => File.join(File.expand_path('~'), '.cargo'),
    }

    system(@rust_envs, 'rustup', 'default', 'stable', out: IO::NULL, err: [:child, :out])
    skip 'rustup not present' unless $?.success?

    system(@rust_envs, 'cargo', '-V', out: IO::NULL, err: [:child, :out])
    skip 'cargo not present' unless $?.success?

    super

    @ext = File.join @tempdir, 'ext'
    @src = File.join @ext, 'src'
    @dest_path = File.join @tempdir, 'prefix'

    FileUtils.mkdir_p @ext
    FileUtils.mkdir_p @src
    FileUtils.mkdir_p @dest_path
  end

  def test_build
    File.open File.join(@ext, 'Cargo.toml'), 'w' do |cargo|
      cargo.write <<-TOML
[package]
name = "test"
version = "0.1.0"
      TOML
    end

    File.open File.join(@src, 'main.rs'), 'w' do |main|
      main.write "fn main() {}"
    end

    output = []

    Dir.chdir @ext do
      ENV.update(@rust_envs)
      Gem::Ext::CargoBuilder.build nil, @dest_path, output
    end

    output = output.join "\n"

    assert_match "Compiling test v0.1.0 (#{@ext})", output
    assert_match "Finished release [optimized] target(s)", output
  end

  def test_build_fail
    output = []

    error = assert_raises Gem::InstallError do
      Dir.chdir @ext do
        ENV.update(@rust_envs)
        Gem::Ext::CargoBuilder.build nil, @dest_path, output
      end
    end

    output = output.join "\n"

    assert_match 'cargo failed', error.message
  end
end
