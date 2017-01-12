module TimeUtils
  # Roughly the inverse of DateHelper::distance_of_time_in_words
  def self.parse_duration_to_seconds(str)
    # Based on https://coderwall.com/p/m3fjjq/converting-distance_of_time_in_words-to-seconds

    # DOES NOT HANDLE 'half a minute','about a minute' among others
    if str
      # ["1", "year,", "11", "months,", "27", "days,", "13", "hours,", "and", "39", "minutes"]
      parts = str.split(' ')
      total_time=0
      parts.each_with_index do |t,index|
        # Converting any string into integer with no actual integer value inside would return zero.
        if t.to_i.zero?
          # If t is 'year' then its predecessor in the array has to be the no of years
          count = parts[index-1].to_i
          # t could be 'month', 'months', 'months,' or even 'month,'
          # Thus, split it with ','
          time_unit = t.split(',').first
        end

        # Converting the count of whatever time_unit into seconds here
        # ex :
        #     count = 3
        #     time_unit = month
        #     3.months.to_i => 7776000
        # Use ActiveSupport::Duration to do the hard work
        if t != "and" and t != "and," and !count.nil? and !time_unit.nil?
          total_time += count.send(time_unit).to_i
        end
      end
      total_time
    end
  end
end
