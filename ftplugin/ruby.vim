if expand('%') =~ '_spec.rb$'
  let b:maque_filetype = 'rspec'
  let b:maque_default_command = 'rspec -b --drb'
endif
