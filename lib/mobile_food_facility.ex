defmodule MobileFoodSodaClient.MobileFoodFacility do
  @moduledoc """
  A mobile food facility.
  """

  alias MobileFoodSodaClient.FacilityLocation

  @typedoc """
  A mobile food facility must be a truck or a push_cart.
  """
  @type facility_types() :: :truck | :push_cart

  @typedoc """
  Address of the mobile food facility. Generally a street number and name.
  """
  @type address() :: String.t()

  @typedoc """
  A description of the food items server at the mobile food facility.
  """
  @type food_items() :: String.t()

  @typedoc """
  Location of the mobile food facility as WGS84 coordinates.
  """
  @type location :: FacilityLocation.t()

  @type t() :: %__MODULE__{
          address: address(),
          facility_type: facility_types(),
          food_items: food_items(),
          location: location(),
          is_cold_truck: boolean()
        }

  @enforce_keys [:location_id, :address, :facility_type]
  defstruct [
    :location_id,
    :address,
    :facility_type,
    :food_items,
    :location,
    :parcel,
    :is_cold_truck
  ]
end
