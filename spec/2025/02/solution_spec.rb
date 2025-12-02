# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Year2025::Day02 do
  let(:input) { File.read(File.join(File.dirname(__FILE__), '../../../challenges/2025/02/input.txt')) }
  let(:example_input) do
    <<~EOF
      11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124
    EOF
  end

  describe 'part 1' do
    it 'returns 1227775554 for the example input' do
      expect(described_class.part_1(example_input)).to eq(1_227_775_554)
    end

    it 'returns 38158151648 for my input' do
      expect(described_class.part_1(input)).to eq(38_158_151_648)
    end
  end

  describe 'part 2' do
    it 'returns 4174379265 for the example input' do
      expect(described_class.part_2(example_input)).to eq(4_174_379_265)
    end

    it 'returns 45283684555 for my input' do
      expect(described_class.part_2(input)).to eq(45_283_684_555)
    end
  end
end
