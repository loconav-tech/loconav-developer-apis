require 'erb'
require 'json'

path = "/home/app/line-haul/config"

files = %w( .env )

files.each do |name|
  File.open("#{path}/#{name}", 'w') do |f|
    f.write ERB.new(File.new("#{path}/template/#{name}.erb").read).result(binding)
  end
end
