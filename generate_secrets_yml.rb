require "erb"
require "json"

path = "/loconav-developer-apis/config/template"

files = %w(.env log_core.yml vt.yml)

files.each do |name|
  File.open("#{path}/#{name}", "w") do |f|
    f.write ERB.new(File.new("#{path}/#{name}.erb").read).result(binding)
  end
end
