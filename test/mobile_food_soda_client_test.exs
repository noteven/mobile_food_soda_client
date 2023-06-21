defmodule MobileFoodSodaClientTest do
  @moduledoc false

  use ExUnit.Case

  alias MobileFoodSodaClient.FacilityPermit

  @csv_file "./support/Mobile_Food_Facility_Permit.csv"
  @json_file "./support/Mobile_Food_Facility_Permit.json"

  describe "client from file" do
    @tag :skip
    test "read CSV coded permits" do
      contents = File.stream!(@csv_file)
      {:ok, facility_permits} = MobileFoodSodaClient.fetch(contents, &CSV.decode/1)

      assert length(facility_permits) > 0

      Enum.each(facility_permits, fn permit ->
        assert %FacilityPermit{} = permit
      end)
    end

    @tag :skip
    test "read JSON coded permits" do
      contents = File.stream!(@json_file)
      {:ok, facility_permits} = MobileFoodSodaClient.fetch(contents, &Jason.decode/1)

      assert length(facility_permits) > 0

      Enum.each(facility_permits, fn permit ->
        assert %FacilityPermit{} = permit
      end)
    end
  end

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
