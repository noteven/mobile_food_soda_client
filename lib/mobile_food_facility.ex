defmodule MobileFoodSodaClient.MobileFoodFacility do
  @moduledoc """
  A mobile food facility.
  """

  alias MobileFoodSodaClient.FacilityLocation

  @typedoc """
  Type of facility: truck, push_cart or nil.
  """
  @type facility_type() :: :truck | :push_cart | nil

  @typedoc """
  A description of the food items server at the mobile food facility.
  """
  @type food_items() :: String.t() | nil

  @typedoc """
  Location of the mobile food facility as WGS84 coordinates.
  """
  @type location :: FacilityLocation.t()

  @type t() :: %__MODULE__{
          facility_type: facility_type(),
          food_items: food_items(),
          location: location()
        }

  @enforce_keys [:location, :facility_type]
  defstruct [
    :facility_type,
    :food_items,
    :location
  ]

  @doc """
  Convert JSON map to a structure instance.
  """
  @spec from_json(map()) :: {:ok, t()} | {:error, any()}
  def from_json(data) do
    with {:ok, facility_type} <- facility_type_from_json(data),
         {:ok, location} <- FacilityLocation.from_json(data) do
      {:ok,
       %__MODULE__{
         facility_type: facility_type,
         food_items: data["fooditems"],
         location: location
       }}
    else
      err ->
        {:error, err}
    end
  end

  @spec facility_type_from_json(map() | String.t()) :: {:ok, facility_type()} | {:error, any()}
  defp facility_type_from_json(%{} = data) when is_map(data) do
    with json_val <- Map.get(data, "facilitytype", ""),
         facility_str <- String.downcase(String.trim(json_val)) do
      facility_type_from_json(facility_str)
    else
      err ->
        {:error, err}
    end
  end

  defp facility_type_from_json("push cart"), do: {:ok, :push_cart}
  defp facility_type_from_json("truck"), do: {:ok, :truck}
  defp facility_type_from_json(""), do: {:ok, nil}

  defp facility_type_from_json(type) when is_binary(type),
    do: {:error, "unrecognized facility type #{type}"}
end
