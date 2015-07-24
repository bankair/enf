# encoding: utf-8

require 'enf/elephant'
require 'enf/elephant/fetch_service'

FetchService = Enf::Elephant::FetchService
describe FetchService do
  describe '.search_in' do
    let(:empty_elephant) { Enf::Elephant.new }

    let(:elephant) do
      result = Enf::Elephant.new
      result.register! 'foo'
      result.register! 'foobar'
      result.register! 'bar'
      result.register! 'barfoo'
      result
    end

    let(:foo_elephant) { 'foo'.split(//).reduce(elephant)       { |e, c| e = e.children.fetch c } }
    let(:bar_elephant) { 'bar'.split(//).reduce(elephant)       { |e, c| e = e.children.fetch c } }
    let(:foobar_elephant) { 'foobar'.split(//).reduce(elephant) { |e, c| e = e.children.fetch c } }

    it { expect{ FetchService.search_in(empty_elephant, 'foo') }.to raise_error KeyError }
    it { expect(FetchService.search_in(empty_elephant, 'foo') { :bar }).to eq :bar }

    it { expect(FetchService.search_in(elephant, 'foo')).to eq foo_elephant }
    it { expect(FetchService.search_in(elephant, 'bar')).to eq bar_elephant }
    it { expect(FetchService.search_in(elephant, 'foobar')).to eq foobar_elephant }
    it { expect{ FetchService.search_in(elephant, '42') }.to raise_error KeyError }

  end
end
