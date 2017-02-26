require 'strscan'

module QueryUtils

  class Tokeniser

    def parse(text)
      @input = StringScanner.new(text)
      output = []

      while keyword = parse_string || parse_quoted_string
        output << keyword.strip unless keyword.blank?
        skip_space
      end

      output
    end

    def parse_string
      if @input.scan(/\w+/)
        @input.matched
      end
    end

    def parse_quoted_string
      if @input.scan(/"/)
        str = parse_quoted_contents
        @input.scan(/"/) or raise "unterminated string"
        str
      end
    end

    def parse_quoted_contents
      @input.scan(/[^\\"]+/) and @input.matched
    end

    def skip_space
      @input.scan(/\s+/)
    end
  end

  # Crappy tokeniser, needs more work
  def self.tokenise(str)
    Tokeniser.new.parse(str)
  end

  # Given parameters, returns a where clause and a set of parameters
  # which can be passed to the where method. E.g
  # params_to_where{id: '[10,12,13]', name: 'ruby'}  => ['id IN ? AND name = ?', [10, 12, 13], 'ruby']
  def self.params_to_where(params, allow_array = {})
    where = ''
    sep = ''
    args = []
    params.each_pair do |key, value|
      if value.blank? 
        where << "#{sep}#{key} IS NULL"
      else
        if allow_array[key.to_sym] && value.is_a?(String) && /^\[.*\]$/.match(value)
          where << "#{sep}#{key} IN (?)"
          # Remove first and last characters then split on comma
          args << value[1..-2].split(',')
        else             
          where << "#{sep}#{key} = ?"
          args << value
        end
      end
      sep = ' AND '
    end
    [where] + args
  end

  # Given a query value q, constructs a ActiveRecord.where method argument array.
  # E.g. q_to_where("XXX", "tab", [:id, :value], [:description]) =>
  # ['tab.id = ? OR tab.value = ? OR tab.descr LIKE ?', 'XXX', 'XXX', '%XXX%']
  def self.q_to_where(q, table, eq_cols, like_cols)
    [(eq_cols.map { |col| "#{table}.#{col} = ?" } +
      like_cols.map { |col| "#{table}.#{col} LIKE ?" }).join(' OR ')] +
      Array.new(eq_cols.length, q) +
      Array.new(like_cols.length, "%#{q}%")
  end

  # Extracts the parameters required for a spatial query from params.
  # Returns a where clause and a set of parameters
  # which can be passed to the where method.
  def self.spatial_query(params, table = 'sites')
    if params[:bounds]
      # Assume value has format "lat_lo,lng_lo,lat_hi,lng_hi"
      bounds = MapHelper::Bounds.new params[:bounds]
      ["#{table}.latitude >= ? AND #{table}.latitude <= ? AND #{table}.longitude >= ? AND #{table}.longitude <= ?",
       bounds.south, bounds.north, bounds.west, bounds.east]
    end
  end
end
