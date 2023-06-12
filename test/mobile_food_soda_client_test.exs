defmodule MobileFoodSodaClientTest do
  @moduledoc false

  use ExUnit.Case

  describe "client" do
    test "allows fetching food truck permits" do
      {:ok, food_trucks} = MobileFoodSodaClient.fetch()

      assert length(food_trucks) > 0

      Enum.each(food_trucks, fn food_truck ->
        assert %FoodTruck{} = food_truck
      end)
    end
  end
end
