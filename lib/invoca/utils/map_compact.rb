module ::Enumerable
  def map_compact
    result = []
    each do |item|
      selected = yield(item)
      result << selected unless selected.nil?
    end
    result
  end
end
