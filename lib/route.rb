class Route
  attr_reader :mode, :route

  def initialize(route)
    @route = route.downcase

    if @route =~ /(?<boro_code>\D)(?<number>\d+)/
      @route = $~[:boro_code] + ("%03d" % $~[:number])
      @mode = :bus
    else
      @mode = :train
    end
  end

  def schedule
    if bus?
      "http://mta.info/nyct/bus/schedule/#{boro}/#{route}cur.pdf"
    else
      "http://mta.info/nyct/service/pdf/t#{route}cur.pdf"
    end
  end

  def map
    if bus?
      "http://mta.info/nyct/bus/schedule/#{boro}/#{route}cur.pdf"
    else
      "http://mta.info/nyct/service/#{route}line.htm"
    end
  end

  def bus?
    mode == :bus
  end

  def mta_mode
    bus? ? "Buses" : "Subways"
  end

  # "Long" version of the route's borough
  def boro
    case route
      when /b/  then "bkln"
      when /bx/ then "bronx"
      when /m/  then "manh"
      when /q/  then "queens"
      when /x/  then "xpress"
    end
  end

  def service_group
    case route
      when /1|2|3/ then "456"
      when /4|5|6/ then "456"
      when /a|c|e/  then "ACE"
      when /b|d|f|m/  then "BDFM"
      when /j|z/  then "JZ"
      when /n|q|r/  then "NQR"
      else route.upcase
    end
  end
end
