# frozen_string_literal: true
require 'rubygems/command'

class Gem::Ext::CargoBuilder < Gem::Ext::Builder
  def self.build(extension, dest_path, results, args=[], lib_dir=nil)
    cmd = 'cargo build --release '
    cmd << " #{Gem::Command.build_args.join ' '}" unless Gem::Command.build_args.empty?
    run cmd, results
    results
  end
end
