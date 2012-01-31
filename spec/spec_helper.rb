$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'fotolia_rest'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

def using_constants(klass, new_constants)
  old_constants = {}
  begin
    new_constants.each_pair do |name, value|
      old_constants[name] = klass.__send__(:remove_const, name)
      klass.const_set(name, value)
    end

    yield
  ensure
    old_constants.each_pair do |name, value|
      klass.__send__(:remove_const, name)
      klass.const_set(name, value)
    end
  end
end

RSpec.configure do |config|
end
