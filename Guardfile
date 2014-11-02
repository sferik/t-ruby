# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec, cli: '--color' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/t/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/helper.rb') { 'spec' }
end
