defmodule MobileFoodSodaClientTest do
  @moduledoc false

  use ExUnit.Case

  alias MobileFoodSodaClient.FacilityPermit

  @csv_file "./support/Mobile_Food_Facility_Permit.csv"
  @json_file "./support/Mobile_Food_Facility_Permit.json"

  describe "from file" do
    test "read CSV coded permits" do
      contents = File.stream!(@csv_file)
      {:ok, facility_permits} = MobileFoodSodaClient.fetch(contents, &CSV.decode/1)

      assert length(facility_permits) > 0

      Enum.each(facility_permits, fn permit ->
        assert %FacilityPermit{} = permit
      end)
    end

    test "read JSON coded permits" do
      contents = File.stream!(@json_file)
      {:ok, facility_permits} = MobileFoodSodaClient.fetch(contents, &Jason.decode/1)

      assert length(facility_permits) > 0

      Enum.each(facility_permits, fn permit ->
        assert %FacilityPermit{} = permit
      end)
    end
  end

  describe "from SODA API" do
  end
end
