#!/usr/bin/env ruby
require 'yaml'

rootDir = ARGV[0]

profiles = {}

Dir.entries(rootDir).select {|f| !File.directory? f}.each do |profile_name|
  manifest_file = File.expand_path("#{profile_name}/manifest.txt", rootDir)

  if File.exists?(manifest_file)
    manifest = File.read(manifest_file).split("\n")
    profiles[profile_name] = { 'manifest' => manifest }
  end
end

index = {'profiles' => profiles}

File.open(File.expand_path('index.yml', rootDir), 'w') { |outFile|
  outFile.write index.to_yaml
}
