# Rack::Domain

[![Build Status](https://travis-ci.org/whatyouhide/rack-domain.svg)](https://travis-ci.org/whatyouhide/rack-domain)
[![Gem Version](https://badge.fury.io/rb/rack-domain.svg)](http://badge.fury.io/rb/rack-domain)
[![Coverage Status](https://coveralls.io/repos/whatyouhide/rack-domain/badge.png)](https://coveralls.io/r/whatyouhide/rack-domain)
[![Inline docs](http://inch-ci.org/github/whatyouhide/rack-domain.svg?branch=master)](http://inch-ci.org/github/whatyouhide/rack-domain)

`Rack::Domain` is a Rack middleware that enables you to intercept a request with
a specific domain or subdomain (or regexp that matches a domain, actually) and
route it to a specific application.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-domain'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-domain


## Usage

`Rack::Domain` supports three kinds of filters in order to match a domain.

- A string: it will match only if the string is exactly the same as the domain.
- A regexp: it will match if the domain matches the regexp.
- An array of strings and regexps: it will match if at least one of the elements
    of the array matches (as described above) the domain.

To decide where to dispatch the request if there's a match, you can use an
existing Rack app through the `:run` option, or you can pass a block in which
you can use the classic `use|run|map...` syntax. This works because the block is
directly passed to a new instance of `Rack::Builder`.

### Examples

Using a regexp:

``` ruby
# Match the 'lobster' subdomain.
use Rack::Domain, /^lobster\./, run: Rack::Lobster.new
```

Using a string:

``` ruby
# Match only if the current domain is github.com:
use Rack::Domain, 'github.com', run: MyGitHubClone
```

Using an array of strings and regexps:

``` ruby
use Rack::Domain, ['lobst.er', /^lobster\./], run: Rack::Lobster.new
```

Using an on-the-fly app build with a `Rack::Builder`-style block:

``` ruby
use Rack::Domain, /^api/ do
  use Rack::Logger
  run MyApi
end
```


## Contributing

Fork, make changes, commit, open Pull Request, be awesome! Read the [GitHub
guide to forking][forking] if you don't know how to.

Also, issues are more than welcome! Open one if you find a bug, you have a
suggestion or simply to ask a question.



[forking]: https://help.github.com/articles/fork-a-repo/
