# Elephants never forget !

Memory lightweight implementation of a white/black list

## Installation

```
gem install enf
```

## Examples

*Building a dictionnary of all terms used in 'Les misérables'*

```ruby
require 'enf'
require 'open-uri'
URI = 'https://www.gutenberg.org/ebooks/135.txt.utf-8'

elephant = Enf::Elephant.new

open(URI) do |file|
  file.read.scan(/[[:alpha:]]*/).each do |token|
    elephant.register! token.downcase
  end
end

elephant.include? 'bonjour'
# => true

elephant.include? 'megadrive'
# => false

```

*Building a shared blacklist with a rack app*

```ruby
require 'rack'
require 'enf'
require 'JSON'

elephant = Enf::Elephant.new

app = Proc.new do |env|
  puts env.inspect
  path = env.fetch('PATH_INFO')
  case path 
  when '/'
    ['200', {'Content-Type' => 'text/html'}, ['A sample elephant black list rack app']]
  when /^\/add\//
    elephant.register!(token = path[5..-1])
    ['200', {'Content-Type' => 'text/html'}, ["Registered '#{token}'"]]
  when /^\/know\//
    result = elephant.include?(token = path[6..-1])
    ['200', {'Content-Type' => 'text/json'}, [{ token => result }.to_json]]
  else
    ['404', {'Content-Type' => 'text/html'}, ['Learn to talk elephantish']]
  end
end
 
Rack::Handler::WEBrick.run app
```



## Note on implementation

Instead of storing all listed values like follow:
```ruby
  {
    "foo"     => true,
    "bar"     => true,
    "foobar"  => true,
    # ...
    "foobob"  => true
  }
```

Those are stored in several nested hashes like follow:

```ruby
  {
    "f" => {
      "o" => {
        "o" => {        # leave
          "b" => {
            "a" => "r", # leave
            "o" => "b"  # leave
          }
        }
      }
    },
    "b" => {
      "a" => "r"        # leave
    }
  }
```

Avoiding duplication of factorizable content.

## Note on performances

Enf::Elephant being sensibly slower than using sets or hashes on small
volume of data, it is recommended to use it when memory matters most and
when words are easily factorizable (example : as a black list for twitter
spam bots).

## Note on completion suggestions

Enf::Elephant are now able to propose completion candidates from a word
beginning, thanks to the 'suggest' method:

```ruby
require 'enf/suggest'
require 'open-uri'
URI = 'https://www.gutenberg.org/ebooks/135.txt.utf-8'

elephant = Enf::Elephant.new

open(URI) do |file|
  file.read.scan(/[[:alpha:]]*/).each do |token|
    elephant.register! token.downcase
  end
end

suggestions = elephant.suggest('ele', limit: 5, incompletes: false)
# => #<Set: {"ven", "venth", "vate", "vated", "vates", "ment",
#            "ments", "gant", "gance", "gy", "onore", "phant",
#            "ct", "ctor", "ctric", "cted", "usiac"}>

puts suggestions.map { |ending| 'ele' + ending }.inspect
# => ["eleven", "eleventh", "elevate", "elevated", "elevates",
#     "element", "elements", "elegant", "elegance", "elegy",
#     "eleonore", "elephant", "elect", "elector", "electric",
#     "elected", "eleusiac"]

```

*Parameters detail:*

* The first non optional parameter is the beginning of the words to search for.
* The limit optional parameter (default: :none) is the number of characters to allow the elephant to inquire for. That parameter allow 2 kinds of value: the :none symbol, that search deeply in the graph for corresponding completion candidates, or a strictly positive integer. (Example: with the value 2, the previous example would have only returned elegy and elect).
* The incompletes optional parameter (default: false) is a boolean parameter allowing to add intermediates incompletes words to the result set. (Example: with limit = 2 and incompletes = true, the previous result set would have been: ['ve', 'va', 'me', 'ga', 'gy', 'on', 'ph', 'ct', 'us'])

## Next ?

I will probably be working on:

1. Single path merging: Now, when a single word uses a specific path
(example: bar, in the previous example), a hash is created for every
letter of that specific path. We have to merge theim as a single element
to avoid useless hash creation.
2. tbd
