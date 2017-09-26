# NameGenerator

A thing that generates pronouncible names.

DISCLAIMER: I make no guarantee that the names this generates are not
inappropriate. They're randomly generated based on arbitrary rules about
English pronunciation, not built off a dictionary of words.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'name_generator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install name_generator

## Usage

    name_generator [--min-length=$MIN_LENGTH] [--max-length=$MAX_LENGTH]

Where `$MIN_LENGTH` defaults to 5 and `$MAX_LENGTH` defaults to 10.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/duckinator/name_generator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NameGenerator project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/duckinator/name_generator/blob/master/CODE_OF_CONDUCT.md).
