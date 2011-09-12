require 'open-uri'
require 'nokogiri'

module Route
  LINES = {
    "red"       => %w{1 2 3},
    "forest"    => %w{4 5 6},
    "blue"      => %w{A C E},
    "orange"    => %w{B D F M},
    "yellow"    => %w{N Q R},
    "chocolate" => %w{J Z},
    "gray"      => %w{L},
    "purple"    => %w{7},
    "green"     => %w{G}
  }

  def self.new(route)
    route = route.downcase

    if match = route.match(/(?<boro>\D)(?<number>\d+)/)
      Bus.new(match[:boro], match[:number])
    else
      Train.new(route)
    end
  end

  def service
    ServiceStatus.new(service_group)
  end

  def bus?
    is_a? Bus
  end

  class Bus
    include Route

    attr_reader :boro, :number

    def initialize(boro, number)
      @boro = boro
      @number = number
    end

    # "Long" version of the route's borough
    def long_boro
      case boro
        when /b/  then "bkln"
        when /bx/ then "bronx"
        when /m/  then "manh"
        when /q/  then "queens"
        when /x/  then "xpress"
      end
    end

    def schedule
      "http://mta.info/nyct/bus/schedule/#{long_boro}/#{padded_route}cur.pdf"
    end

    def mode
      "Buses"
    end

    def padded_route
       boro + ("%03d" % number)
    end

    def to_s
      (boro + number).upcase!
    end

    def service_group
      case boro
        when 'b'   then (1..83).include?(number.to_i) ? "B1 - B83" : "B100 - B103"
        when 'bm'  then "BM1 - BM5"
        when 'bx'  then "BX1 - BX55"
        when 'bxm' then "BXM1 - BXM18"
        when 'm'   then "M1 - M116"
        when 'n'   then "N1 - N88"
        when 'q'   then "Q1 - Q113"
        when 'qm'  then "QM1 - QM25"
        when 's'   then "S40 - S98"
        when 'x'   then "x1 - x68"
      end
    end
  end

  class Train
    include Route

    attr_reader :route

    def initialize(route)
      @route = route
    end

    def schedule
      "http://mta.info/nyct/service/pdf/t#{route}cur.pdf"
    end

    def map
      "http://mta.info/nyct/service/#{map_route}.htm"
    end

    def map_route
      return route + "line" if route.to_i.zero?
      name = case route.to_i
        when 1 then "one"
        when 2 then "two"
        when 3 then return "threelin"
        when 4 then "four"
        when 5 then "five"
        when 6 then "six"
        when 7 then return "sevenlin"
      end + "line"
    end

    def mode
      "Subways"
    end

    def to_s
      route.upcase
    end

    def color
      LINES.detect do |color, trains|
        color if trains.include? self.to_s
      end.first
    end

    def service_group
      case route
        when /1|2|3/   then "123"
        when /4|5|6/   then "456"
        when /a|c|e/   then "ACE"
        when /b|d|f|m/ then "BDFM"
        when /j|z/     then "JZ"
        when /n|q|r/   then "NQR"
        else route.upcase
      end
    end
  end

  class ServiceStatus
    def initialize(group)
      root = Nokogiri::HTML(document).xpath("//name[.='#{group}']").first.parent
      @status = root.xpath("status").text
    end

    def status
      @status.capitalize
    end

    def bad?
      @status != "GOOD SERVICE"
    end

    def document
      open 'http://www.mta.info/status/serviceStatus.txt'
    end
  end
end
