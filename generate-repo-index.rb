#!/usr/bin/env ruby
require 'yaml'

rootDir = ARGV[0]

profiles = {}

Dir.entries(rootDir).select {|f| !File.directory? f}.each do |profile_name|
  manifest_file = File.expand_path("#{profile_name}/manifest.txt", rootDir)
  tags_file = File.expand_path("#{profile_name}/tags.txt", rootDir)

  if File.exists?(manifest_file)
    profile = {}

    manifest = File.read(manifest_file).split("\n")
    profile['manifest'] = manifest

    if File.exists(tags_file)
      tags = File.read(tags_file).split("\n")
      profile['tags'] = tags
    end

    profiles[profile_name] = profile
  end
end

index = {'profiles' => profiles}

File.open(File.expand_path('index.yml', rootDir), 'w') { |outFile|
  outFile.write index.to_yaml
}
