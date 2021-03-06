# encoding: utf-8

require 'enf/elephant'

CannotRegister = Enf::Elephant::CannotRegister
describe Enf::Elephant do
  subject(:node) { Enf::Elephant.new }
  INVALID_INPUTS = [nil, 2].freeze
  VALID_INPUTS = [[1, 2, 3], 'string'].freeze
  ANY_INPUTS = (INVALID_INPUTS + VALID_INPUTS).freeze
  describe '#include?' do
    it { expect(node.include?(nil)).to be false }
    it { expect(node.include?(2)).to be false }
    it { expect(node.include?('string')).to be false }
  end
  describe '#register' do
    INVALID_INPUTS.each do |invalid|
      it "raise error when given #{invalid.inspect}" do
        expect { node.register!(invalid) }.to raise_error CannotRegister
      end
    end
    VALID_INPUTS.each do |valid|
      it "do not raise error when given #{valid.inspect}" do
        expect { node.register!(valid) }.not_to raise_error
      end
    end
  end

  context 'When using default payload' do
    ABC_IS_THE_ONLY_KNOWN_VALUE = 'abc is the only known value'
    shared_examples ABC_IS_THE_ONLY_KNOWN_VALUE do
      it { expect(node.include?('abc')).to be true }
      it { expect(node.include?('')).to be false }
      %w(a ab b abcd).each do |unknown|
        it "do not include #{unknown.inspect}" do
          expect(node.include?(unknown)).to be false
        end
      end
    end

    context 'When using arrays as element sequences' do
      before(:each) do
        node.register! [1]
        node.register! [1, 2]
        node.register! [2, 3]
        node.register! [1, 2, 3]
      end
      it { expect(node.include? [1] ).to be true }
      it { expect(node.include? [1, 2] ).to be true }
      it { expect(node.include? [1, 2, 3] ).to be true }
      it { expect(node.include? [2, 3] ).to be true }
      it { expect(node.include? [3] ).to be false }
      it { expect(node.include? [1, 3] ).to be false }
    end

    context 'When "abc" is registered' do
      before(:each) { node.register! 'abc' }
      it_behaves_like ABC_IS_THE_ONLY_KNOWN_VALUE
      context 'When "abc" is registered a second time' do
        before(:each) { node.register! 'abc' }
        it_behaves_like ABC_IS_THE_ONLY_KNOWN_VALUE
      end

      context 'When "a" is registered' do
        before(:each) { node.register! 'a' }
        %w(a abc).each do |known|
          it "include #{known.inspect}" do
            expect(node.include?(known)).to be true
          end
        end
        %w(ab b abcd).each do |unknown|
          it "do not include #{unknown.inspect}" do
            expect(node.include?(unknown)).to be false
          end
        end

        context 'When "abcd" is registered' do
          before(:each) { node.register! 'abcd' }
          %w(a abc abcd).each do |known|
            it "include #{known.inspect}" do
              expect(node.include?(known)).to be true
            end
          end
          %w(b ab).each do |unknown|
            it "do not include #{unknown.inspect}" do
              expect(node.include?(unknown)).to be false
            end
          end
        end

        context 'When "" (an empty string) is registered' do
          before(:each) { node.register! '' }
          it('include ""') { expect(node.include?('')).to be true }
        end
      end
    end

    describe Enf::Elephant::Nope do
      subject(:nope) { Enf::Elephant::Nope.new }
      describe '#register' do
        ANY_INPUTS.each do |any_input|
          it "raise error when given #{any_input}" do
            expect { nope.register!(any_input) }.to raise_error CannotRegister
          end
        end
      end
    end
  end
end
