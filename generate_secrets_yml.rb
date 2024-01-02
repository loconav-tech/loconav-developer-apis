require "erb"
require "json"

path = "loconav-developer-apis/config/template"

files = %w(.env log_core.yml)

files.each do |name|
  File.open("#{path}/#{name}", "w") do |f|
    f.write ERB.new(File.new("#{path}/template/#{name}.erb").read).result(binding)
  end
end
