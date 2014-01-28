guard :shell, all_on_start: true do
  watch(/riml\/(.*).riml$/) do |file, base|
    dir = File.dirname(base)
    `mkdir -p autoload/#{dir}`
    `riml -c #{file} -o autoload/#{dir}`
  end
end
