require 'rspec'
require 'spec_helper'
require 'app_helper.rb'
require 'benchmark'

describe "#create_email_list" do
  it "contains double the amount of elements as the input value" do
    expect(create_email_list(50_000).length).to eq(100_000)
  end
end

describe "#remove_duplicates" do
  let(:array) {create_email_list(50_000)}

  it "removes duplicate elements" do
    count_hash = Hash.new(0)
    result = remove_duplicates(array)
    result.each { |el| count_hash[el] += 1 }
    duplicate_elements = result.select { |el| count_hash[el] > 1 }
    expect(duplicate_elements).to eq([])
  end

  it "contains every distinct element in the input array" do
    expect(remove_duplicates(array)).to match_array(array.uniq)
  end

  it "leaves the array in the same order as the input" do
    expect(remove_duplicates(array)).to eq(array.uniq)
  end

  context "with no items" do
    let(:empty_arr) {[]}
    it "returns an empty array" do
      expect(remove_duplicates(empty_arr)).to eq(empty_arr)
    end
  end

  context "with an input containing no duplicates" do
    let(:no_dups) {(1..100_000).to_a.shuffle!}
    it "matches the input" do
      expect(remove_duplicates(no_dups)).to match_array(no_dups)
    end
  end

  context "with 100,000 inputs" do
    it "should complete in under 1 second" do
      expect(Benchmark.realtime{ remove_duplicates(array)}).to be < 1
    end
  end
end
