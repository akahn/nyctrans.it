require_relative "../lib/route.rb"

describe Route do
  context ".new" do
    it "should return a bus" do
      Route.new("b63").should be_a(Route::Bus)
    end

    it "should return a train" do
      Route.new("g").should be_a(Route::Train)
    end
  end
end

describe Route::Bus do
  it "should have a long boro" do
    Route::Bus.new("m", "60").long_boro.should == "manh"
  end

  it "should be able to zero-pad the route" do
    Route::Bus.new("m", "60").padded_route.should == "m060"
  end

  it "should have a schedule URL" do
    Route::Bus.new("b", "62").schedule.should ==
      "http://mta.info/nyct/bus/schedule/bkln/b062cur.pdf"
  end

  it "should find the brooklyn service group" do
    Route::Bus.new('b', '63').service_group.should == "B1 - B83"
    Route::Bus.new('b', '100').service_group.should == "B100 - B103"
  end
end

describe Route::Train do
  it "should have a schedule URL" do
    Route::Train.new("c").schedule.should ==
      "http://mta.info/nyct/service/pdf/tccur.pdf"
  end

  it "should have a map URL" do
    Route::Train.new("c").map.should ==
      "http://mta.info/nyct/service/cline.htm"
  end

  it "should point from c to ACE" do
    Route::Train.new("c").service_group.should == "ACE"
  end

  it "should handle the fallback cases" do
    Route::Train.new("g").service_group.should == "G"
  end
end

describe Route::ServiceStatus do
  class Route::ServiceStatus
    def document
      File.read("./spec/service.xml")
    end
  end

  context "with good service" do
    before { @service = Route::ServiceStatus.new("456") }

    it "should show good service" do
      @service.status.should == "Good service"
    end

    it "should report good service" do
      @service.bad?.should be_false
    end
  end

  context "with bad service" do
    before { @service = Route::ServiceStatus.new("ACE") }

    it "should show work status" do
      @service.status.should == "Planned work"
    end

    it "should report bad service" do
      @service.bad?.should be_true
    end
  end
end
