require 'open-uri'
require 'nokogiri'

class Route
  attr_reader :mode, :route, :number, :boro

  def initialize(route)
    @route = route.downcase

    if @route =~ /(?<boro_code>\D)(?<number>\d+)/
      @boro = $~[:boro_code]
      @number = $~[:number]
      @mode = :bus
    else
      @mode = :train
    end
  end

  def schedule
    if bus?
      "http://mta.info/nyct/bus/schedule/#{long_boro}/#{padded_route}cur.pdf"
    else
      "http://mta.info/nyct/service/pdf/t#{route}cur.pdf"
    end
  end

  def map
    if bus?
      "http://mta.info/nyct/bus/schedule/#{long_boro}/#{padded_route}cur.pdf"
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

  def padded_route
     boro + ("%03d" % number)
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

  def service
    ServiceStatus.new(service_group)
  end

  def service_group
    if bus?
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
    else
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
