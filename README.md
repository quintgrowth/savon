# Reste

Heavy metal SOAP client

[Documentation](http://resterb.com) | [RDoc](http://rubydoc.info/gems/reste) |
[Mailing list](https://groups.google.com/forum/#!forum/resterb) | [Twitter](http://twitter.com/resterb)

[![Build Status](https://secure.travis-ci.org/resterb/reste.png?branch=version2)](http://travis-ci.org/resterb/reste)
[![Gem Version](https://badge.fury.io/rb/reste.png)](http://badge.fury.io/rb/reste)
[![Code Climate](https://codeclimate.com/github/resterb/reste.png)](https://codeclimate.com/github/resterb/reste)
[![Coverage Status](https://coveralls.io/repos/resterb/reste/badge.png?branch=version2)](https://coveralls.io/r/resterb/reste)


## Version 2

Reste version 2 is available through [Rubygems](http://rubygems.org/gems/reste) and can be installed via:

```
$ gem install reste
```

or add it to your Gemfile like this:

```
gem 'reste', '~> 2.3.0'
```

## Usage example

``` ruby
require 'reste'

# create a client for the service
client = Reste.client(wsdl: 'http://service.example.com?wsdl')

client.operations
# => [:find_user, :list_users]

# call the 'findUser' operation
response = client.call(:find_user, message: { id: 42 })

response.body
# => { find_user_response: { id: 42, name: 'Hoff' } }
```

For more examples, you should check out the
[integration tests](https://github.com/resterb/reste/tree/version2/spec/integration).


## Give back

If you're using Reste and you or your company is making money from it, then please consider
donating via [Gittip](https://www.gittip.com/tjarratt/) so that I can continue to improve it.

[![donate](donate.png)](https://www.gittip.com/tjarratt/)


## Documentation

Please make sure to [read the documentation](http://resterb.com/version2/).

And if you find any problems with it or if you think something's missing,
feel free to [help out and improve the documentation](https://github.com/resterb/resterb.com).

Donate icon from the [Noun Project](http://thenounproject.com/noun/donate/#icon-No285).
