require "rails_helper"

RSpec.describe BookingsController, type: :routing do
  describe "routing" do
    it "routes to user session checker" do
      expect(get: "/sessions/alive").to route_to("sessions#alive")
    end
  end
end
