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

    if File.exists?(tags_file)
      tags = File.read(tags_file).split("\n")
      profile['tags'] = tags
    end

    if Dir.exists?("#{rootDir}/#{profile_name}/initialize.d") || Dir.exists?("#{rootDir}/#{profile_name}/preconfigure.d")
      # Automagically tag profile as startup
      if !profile.key?('tags')
        profile['tags'] = []
        File.write(tags_file, "startup\n")
      end
      if !profile['tags'].include?('startup')
        # tags were specified but startup was not. We should fix that:
        File.open(tags_file, 'a') { |f| f.write("startup\n") }
        profile['tags'] << 'startup'
      end
    end

    profiles[profile_name] = profile
  end
end

index = {'profiles' => profiles}

File.open(File.expand_path('index.yml', rootDir), 'w') { |outFile|
  outFile.write index.to_yaml
}
