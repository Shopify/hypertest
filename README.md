# Hypertest

Hypertest is a very simple tool to help you run fast test suites in a very tight
dev loop on file changes.

## Installation

Add `gem 'hypertest'` to your Gemfile, maybe in a `:development, :test` group,
then `bundle install`. `gem 'bootsnap'` is also recommended.

Generally you will want to use Hypertest by creating a file like:

```ruby
#!/usr/bin/env ruby
# bin/hypertest

require 'bundler/setup'
Bundler.require(:development, :test)

ROOT = File.expand_path('..', __dir__)
$LOAD_PATH.unshift(File.join(ROOT, 'lib'))
$LOAD_PATH.unshift(File.join(ROOT, 'test'))

# Bootsnap isn't necessary but generally speeds things up even further.
Bootsnap.setup(
  cache_dir:          "#{ROOT}/tmp/cache",
  ignore_directories: [],
  development_mode:   true,
  load_path_cache:    true,
  compile_cache_iseq: true,
  compile_cache_yaml: true,
  compile_cache_json: true,
  readonly:           false,
)

Hypertest.run do
  require 'test_helper'
  Dir.glob('test/**/*_test.rb').each do |file|
    require File.join(ROOT, file)
  end
end
```

This loads ruby and your bundle, then forks to load your test helper and tests
after each file change. Happy hacking!
