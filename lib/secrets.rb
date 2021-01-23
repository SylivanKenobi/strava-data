require 'yaml'

class Secrets
  class << self
    def get(secret)
      if File.file?('assets/secrets.yml')
        File.open('assets/secrets.yml') { |file| YAML.safe_load(file) }[secret]
      else
        ENV[secret]
      end
    end
  end
end
