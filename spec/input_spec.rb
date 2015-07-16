# encoding: utf-8

require 'enf/input'

describe Enf::Input do
  describe '.invalid?' do
    [nil, :foo, 42, 2.5].each do |invalid|
      it "return true when given #{invalid.inspect}" do
        expect(Enf::Input.invalid?(invalid)).to be true
      end
    end
    ['a nice string', [1, 2, 3]].each do |valid|
      it "return false when given #{valid.inspect}" do
        expect(Enf::Input.invalid?(valid)).to be false
      end
    end
  end
end
