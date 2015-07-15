# Elephants never forget !

Memory lightweight implementation of a white/black list

## Examples

*Building a dictionnary of all terms used in 'Les misérables'*

```ruby
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

## Next ?

I will probably be working on:

1. Single path merging: Now, when a single word uses a specific path
(example: bar, in the previous example), a hash is created for every
letter of that specific path. We have to merge theim as a single element
to avoid useless hash creation.
2. Completion: With that data structure, it will be quite easy and
efficient to propose completion candidates from a start of word.
3. tbd
