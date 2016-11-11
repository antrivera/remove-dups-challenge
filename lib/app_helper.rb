def create_email_list(num_unique)
  emails = []
  num_unique.times { |i| emails << "user#{i}@gmail.com" }
  emails *= 2
  emails.shuffle!
end

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
