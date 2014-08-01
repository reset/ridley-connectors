notification :off

guard 'rspec', cmd: "bundle exec rspec --color", all_on_start: false, all_after_pass: false do
  watch(%r{^spec/unit/.+_spec\.rb$})
  watch(%r{^spec/acceptance/.+_spec\.rb$})

  watch(%r{^lib/(.+)\.rb$})          { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')       { "spec" }
  watch(%r{^spec/support/.+\.rb$})   { "spec" }
end
