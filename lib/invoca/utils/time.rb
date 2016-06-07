# Invoca ::Time extensions
class ::Time
  def to_ms
    @to_ms ||= (self.to_f * 1000).to_i
  end

  #rfc3339ms is like rfc3339 but with milliseconds
  if RUBY_VERSION < "1.9.3"
    def rfc3339ms
      strftime("%Y-%m-%dT%H:%M:%S.#{ms_for_3339}%z")
    end

    def ms_for_3339
      @ms_for_3339 ||= ("%03.3d" % (self.to_ms % 1000))
    end
    private :ms_for_3339
  else
    def rfc3339ms
      strftime("%Y-%m-%dT%H:%M:%S.%L%z")
    end
  end

  def beginning_of_hour
    change(:min => 0, :sec => 0, :usec => 0)
  end

  def end_of_day_whole_sec # usec can be bad because it isn't preserved by MySQL
    change(:hour => 23, :min => 59, :sec => 59, :usec => 0)
  end

  def whole_sec
    change(:usec => 0)
  end
end
