# Class for working with view angles of photos of specimens.
# The angle is specified by latitude (phi) and longitude (lambda).  Photos
# are assumed to be directed towards the centre of the specimen, with
# the top of the specimen facing up or else the front of the specimen
# facing towards the left. Longitude (lamba) is 0 at the middle of the
# face. Units are (integral) degrees.

# Hence, a frontal view is (0, 0), a lateral view (taken from the
# specimen's left side) is (0, 90), and a dorsal view is (90, 0).
#
# See also http://insects.oeb.harvard.edu/etypes/specificimages.htm
class ViewAngle
  include Comparable
  attr_accessor :phi, :lambda

  NAMED_ANGLES = {lateral: [0, 90],
                  dorsal: [90, 0],
                  ventral: [-90, 0],
                  frontal: [0, 0],
                  posterior: [0, 180],
                  lateral_right_side: [0, -90]
                 }
  SYNONYMS = {anterior: [0, 0],
              face: [0, 0],
              underside: [-90, 0]}

  # Returns the list of named angles
  def self.angle_names
    NAMED_ANGLES.keys
  end

  # If params contains a parameter such as {view_angle: 'lateral'}, removes it and
  # adds {view_phi: 0, view_lambda: 90}
  def self.expand_query_params(params)
    if params.key?(:view_angle) && (va = ViewAngle.new(params[:view_angle])) && va.valid?
      params = params.merge(view_phi: va.phi, view_lambda: va.lambda)
    end
    params.except(:view_angle)
  end

  # Creates a ViewAngle.
  # Takes either a view name (a symbol or string), phi and lambda, or a name and relative phi and lambda.
  # 
  # Examples:
  # ViewAngle.new(:lateral) # Taken from left side
  # ViewAngle.new(0, 90) # Same as :lateral
  # ViewAngle.new('0, 90') # Same as :lateral
  # ViewAngle(:dorsal) # Taken from above, head towards the left (by convention)
  # ViewAngle(:dorsal, -5, 90) # Taken from above by 5 degrees towards dorsal
  def initialize(phi_or_name, lambda_or_relative_phi = 0, relative_lambda = 0)
    if phi_or_name.is_a?(Numeric) && lambda_or_relative_phi.is_a?(Numeric)
      @phi = phi_or_name
      @lambda = lambda_or_relative_phi
    elsif !phi_or_name.blank?
      # Check for 2 angles in a string
      phi_or_name = phi_or_name.to_s
      if (m = phi_or_name.scan(/[+-]?\d+/)) && m.length == 2
        @phi = m[0].to_i
        @lambda = m[1].to_i
      else
        # Check for name of an angle
        key = phi_or_name.parameterize(separator: '_').intern
        na = NAMED_ANGLES[key]
        na = SYNONYMS[key] if na.blank?
        raise ArgumentError, "Invalid named view angle '#{phi_or_name}', require one of [#{NAMED_ANGLES.keys.join(', ')}]" if na.blank?
        @phi = na[0]
        @lambda = na[1]

        # Add relative angle if specified
        if lambda_or_relative_phi.is_a?(Numeric) && relative_lambda.is_a?(Numeric)
          @phi += lambda_or_relative_phi
          @lambda += relative_lambda
        end
      end
    end
  end

  def valid?
    !@phi.nil? && !@lambda.nil? && @phi >= -90 && @phi <= 90 && @lambda >= -180 && @lambda <= 180
  end

  def to_s
    valid? ? (name && name.humanize || "#{@phi}, #{@lambda}") : ''
  end

  def inspect
    "ViewAngle(phi: #{@phi}, lambda: #{@lambda}, name: #{name})"
  end

  def description
    valid? ? "#{to_s.humanize} view" : ''
  end
  
  def name
    nm = false
    NAMED_ANGLES.each do |key, value|
      nm = key.to_s if value[0] == @phi && value[1] == @lambda
    end
    nm
  end

  def hash
    [phi, lambda].hash
  end

  def eql?(other)
    self == other || (other.is_a?(ViewAngle) && phi == other.phi && lambda == other.lambda)
  end    

  # Define a somewhat arbitrary ordering, based on how photos should appear
  def <=>(other)
    if other.is_a? ViewAngle
      nm1 = name
      nm2 = other.name
      # Named angles come first
      return -1 if nm1 && !nm2
      return 1 if !nm1 && nm2
      # String comparison if neither is named
      return to_s <=> other.to_s if !nm1
      # Named angles use the order defined in NAMED_ANGLES
      idx1 = NAMED_ANGLES.keys.index(nm1.to_sym)
      idx2 = NAMED_ANGLES.keys.index(nm2.to_sym)
      idx1 <=> idx2
    end
  end
  
end
