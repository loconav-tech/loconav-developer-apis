require "erb"
require "json"

path = "/loconav-developer-apis/config"

files = %w(.env secrets.yml database.yml)

files.each do |name|
  File.open("#{path}/#{name}", "w") do |f|
    f.write ERB.new(File.new("#{path}/template/#{name}.erb").read).result(binding)
  end
end
