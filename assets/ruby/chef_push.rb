node = ENV['NODE']
recipe = ENV['RECIPE']

nodes.transform("name:#{node}") do |n|
  n.set['push_jobs']['whitelist']['maque'] =
    "chef-client -o 'recipe[#{recipe}]'"
end
