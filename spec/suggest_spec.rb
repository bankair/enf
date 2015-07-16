# encoding: utf-8

require 'enf/suggest'

Complete = Enf::Complete
SuggestParamError = Complete::SuggestParamError

describe Complete do
  let(:elephant) { Enf::Elephant.new }
  describe '.suggest' do
    [nil, :lizard, 2].each do |faulty_input|
      it "raise a SuggestParamError if given #{faulty_input}" do
        expect{elephant.suggest(faulty_input)}.to raise_error SuggestParamError
      end
    end

    context 'When the elephant knows nothing' do
      it { expect(elephant.suggest('foo')).to be_empty }
      it { expect(elephant.suggest('')).to be_empty }
    end

    TOKENS = %w(far foo foobar foobob bar barfoo foob fooo alice bob boofar)

    context 'When the elphant knows shits' do
      before(:each) { TOKENS.each { |token| elephant.register!(token) } }
      context 'When not restricted' do
        {
          foo: %w(foo foobar foobob foob fooo),
          foob: %w(foobar foobob foob),
          fa: %w(far),
          f: %w(far foo foobar foobob foob fooo),
          b: %w(bar barfoo bob boofar),
          ba: %w(bar barfoo)
        }.each do |start, array|
          start = String start
          it "return #{array.inspect} when given #{start}" do
            array = array.map { |value| value.sub(start, '') }
            expect(elephant.suggest(start)).to match_array array
          end
        end
      end

      context 'When limit is set to 1 and incomplete is true' do
        {
          foo: %w(foo foob fooo),
          foob: %w(foob fooba foobo),
          fa: %w(far),
          f: %w(fo fa),
          b: %w(ba bo),
          ba: %w(bar)
        }.each do |start, array|
          start = String start
          it "return #{array.inspect} when given #{start}" do
            array = array.map { |value| value.sub(start, '') }
            suggestions = elephant.suggest(start, limit: 1, incompletes: true)
            expect(suggestions).to match_array array
          end
        end
      end


      context 'When limit is set to 1 and incomplete is false' do
        {
          foo: %w(foo foob fooo),
          foob: %w(foob),
          fa: %w(far),
          f: [],
          b: [],
          ba: %w(bar)
        }.each do |start, array|
          start = String start
          it "return #{array.inspect} when given #{start}" do
            array = array.map { |value| value.sub(start, '') }
            suggestions = elephant.suggest(start, limit: 1, incompletes: false)
            expect(suggestions).to match_array array
          end
        end
      end

      context 'When limit is set to 3 and incomplete is false' do
        {
          '' => %w(bar foo bob far)
        }.each do |start, array|
          start = String start
          it "return #{array.inspect} when given #{start}" do
            array = array.map { |value| value.sub(start, '') }
            suggestions = elephant.suggest(start, limit: 3, incompletes: false)
            expect(suggestions).to match_array array
          end
        end
      end

    end

  end
end
