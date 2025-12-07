# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Year2025::Day06 do
  let(:input) { File.read(File.join(File.dirname(__FILE__), '../../../challenges/2025/06/input.txt')) }
  let(:example_input) do
    <<~EOF
      123 328  51 64#{' '}
       45 64  387 23#{' '}
        6 98  215 314
      *   +   *   +#{'  '}
    EOF
  end

  describe 'part 1' do
    it 'returns 4277556 for the example input' do
      expect(described_class.part_1(example_input)).to eq(4_277_556)
    end

    it 'returns 6417439773370 for my input' do
      expect(described_class.part_1(input)).to eq(6_417_439_773_370)
    end
  end

  describe 'part 2' do
    it 'returns 3263827 for the example input' do
      expect(described_class.part_2(example_input)).to eq(3_263_827)
    end

    # it 'returns nil for my input' do
    #   expect(described_class.part_2(input)).to eq(nil)
    # end
  end
end
