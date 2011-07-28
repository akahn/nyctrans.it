require_relative "../lib/route.rb"

describe Route do
  context "#long_boro" do
    it "should be manh" do
      Route.new("m60").long_boro.should == "manh"
    end
  end

  context "#bus?" do
    it "should be a bus" do
      Route.new("m60").bus?.should be_true
    end

    it "should not be a bus" do
      Route.new("c").bus?.should be_false
    end
  end

  context "bus" do
    it "should have a schedule URL" do
      Route.new("b62").schedule.should ==
        "http://mta.info/nyct/bus/schedule/bkln/b062cur.pdf"
    end

    it "should have a map URL" do
      Route.new("b62").map.should ==
        "http://mta.info/nyct/bus/schedule/bkln/b062cur.pdf"
    end

    it "should find the brooklyn service group" do
      Route.new('b63').service_group.should == "B1 - B83"
      #Route.new('b100').service_group.should == "B100 - B103"
    end
  end

  context "train" do
    it "should have a schedule URL" do
      Route.new("c").schedule.should ==
        "http://mta.info/nyct/service/pdf/tccur.pdf"
    end

    it "should have a map URL" do
      Route.new("c").map.should ==
        "http://mta.info/nyct/service/cline.htm"
    end
  end

  context "#service_group" do
    it "should point from c to ACE" do
      Route.new("c").service_group.should == "ACE"
    end

    it "should handle the fallback cases" do
      Route.new("g").service_group.should == "G"
    end
  end
end
