defmodule MobileFoodSodaClientTest do
  @moduledoc false

  use ExUnit.Case

  alias MobileFoodSodaClient.FacilityPermit

  describe "client from SODA API" do
    test "can fetch permits" do
      {:ok, facility_permits} = MobileFoodSodaClient.fetch()

      assert length(facility_permits) > 0

      Enum.each(facility_permits, fn permit ->
        assert %FacilityPermit{} = permit
      end)
    end
  end
end
