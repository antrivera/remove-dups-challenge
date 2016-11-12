# Question #5

A function that removes all duplicates from an unsorted list of email addresses.

Requirements:
- Resulting list remains in the same order as the input
- Function should be able to handle 100,000 email addresses containing 50% randomly placed duplicates in under 1 second on a modern laptop

## How to Use

The function can be tested through the simple front-end interface, or by sending a `POST` request to `http://remove-duplicates-demo.herokuapp.com/unique_emails` in the following JSON format:

```
  { "emails":
    [ "email1@sample.com",
      ...
      "emailn@demo.com"
    ]
  }
```

A sample email list may be obtained by sending a `GET` request to `http://remove-duplicates-demo.herokuapp.com/emails` with a key-value pair query parameter of `unique=n`, where n is the number of unique email addresses that is desired.  Note that the returned list is twice this size, with the extra elements consisting of duplicates. Order is randomized.

## Implementation

I chose to implement the function in Ruby as follows:

```ruby
def remove_duplicates(arr)
  unique_hash = {}
  unique_arr = []

  arr.each do |el|
    if unique_hash[el].nil?
      unique_hash[el] = 1
      unique_arr << el
    end
  end

  unique_arr
end
```
The naive way to implement this function would be to have a nested loop that iterates over the array of encountered email addresses for every element in the input array to ensure that no address is added to the returned encountered/unique array twice.  However, the time complexity of such a method would be O(n^2).

I chose instead to utilize a hash to keep track of all encountered email addresses, and relied upon the fast O(1) lookup to ensure that no duplicates were added to the output array. With this method, the time complexity is merely O(n), which is the fastest conceivable runtime.  However, it does require extra O(n) space.

A couple of notes:
 - Ruby actually has a `Hash#keys` method which returns an array of all inserted keys in the hash.  Additionally, as of Ruby 1.9 these keys are returned in insertion order.  However, I chose to include the `unique_arr` array and explicitly push values onto it for clarity and because in older versions of Ruby, hash order was not guaranteed
 - To mutate the input array, this variation could be used:

 ```ruby
 def mutating_remove_duplicates(arr)
  unique_hash = {}

  slow = 0
  (0...arr.length).each do |fast|
    email = arr[fast]
    if unique_hash[email].nil?
      unique_hash[email] = 1
      arr[slow], arr[fast] = arr[fast], arr[slow] unless slow == fast
      slow += 1
    end
  end

  arr[0...slow]
end
```

However, `arr[0...slow]` still returns a new array, so the original input will still contain all duplicates in its latter half (i.e. `arr[slow+1..-1]`). As far as I know, Ruby does not have an array method that can slice off multiple elements without allocating a new array of some sort, even if only to return the elements that have been sliced out.  Therefore, I decided to go with the former, simpler implementation.  If the method really did want to mutate its input, then it could be modified to return the new size of the valid, unique portion of the array (marked here by `slow`).  This would be useful in a language with fixed size arrays, such as C.

## Test Suite

I wrote a simple test suite using Rspec to ensure that the requirements were met.

```ruby
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
```

Benchmark results on my machine (2014 MacBook Pro):

```
Rehearsal ------------------------------------------------------
remove_duplicates:   0.060000   0.000000   0.060000 (  0.065140)
--------------------------------------------- total: 0.060000sec

                         user     system      total        real
remove_duplicates:   0.050000   0.000000   0.050000 (  0.058108)
```

## Deployment

I used Sinatra for my simple server and Heroku for deployment.  The front-end makes use of an AJAX call to obtain and display the unique email addresses.  Some error checking was included to ensure valid inputs, but there is no size limit on the requests at the moment so problems will be encountered if requesting extremely large lists.  However, 100,000 emails are handled without problems.
