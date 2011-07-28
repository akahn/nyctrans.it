require 'open-uri'
require 'nokogiri'

module Route
  def self.new(route)
    route.downcase!

    if match = route.match(/(?<boro>\D)(?<number>\d+)/)
      Bus.new(match[:boro], match[:number])
    else
      Train.new(route)
    end
  end

  module Service
    def service
      ServiceStatus.new(service_group)
    end
  end

  class Bus
    include Service

    attr_reader :boro, :number

    def initialize(boro, number)
      @boro = boro
      @number = number
      self
    end

    # "Long" version of the route's borough
    def long_boro
      case route
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

    def map
      "http://mta.info/nyct/bus/schedule/#{long_boro}/#{padded_route}cur.pdf"
    end

    def mode
      "Buses"
    end

    def padded_route
       boro << ("%03d" % number)
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
    include Service

    attr_reader :route

    def initialize(route)
      @route = route
    end

    def schedule
      "http://mta.info/nyct/service/pdf/t#{route}cur.pdf"
    end

    def map
      "http://mta.info/nyct/service/#{route}line.htm"
    end

    def mode
      "Subways"
    end

    def service_group
      case route
        when /1|2|3/   then "456"
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
    attr_reader :status, :text

    def initialize(group)
      root = document.xpath("//name[.='#{group}']").first.parent
      @status = root.xpath("status").text
      @text = root.xpath("text").text
      @good_service = @status == "GOOD SERVICE"
      self
    end

    def bad?
      !@good_service
    end

    def document
      Nokogiri::XML(open('http://mta.info/status/serviceStatus.txt'))
    end
  end
end
