defmodule MobileFoodSodaClient.FacilityLocation do
  @moduledoc """
  The WGS84 latitude and longitude of a facility.
  """

  @typedoc """
  Location ID assigned by San Francisco Mobile Food Facility API.
  """
  @type location_id() :: number()

  @typedoc """
  WGS84 coordinate.
  """
  @type coordinate() :: number() | nil

  @typedoc """
  Description of the location indicated by the coordinates.
  """
  @type description() :: String.t() | nil

  @typedoc """
  Human readable address of the mobile food facility. Generally a street number and name,
  ex:  324 Some Street.
  """
  @type address() :: String.t()

  @type t() :: %__MODULE__{
          id: location_id(),
          address: address(),
          longitude: coordinate(),
          latitude: coordinate(),
          description: description()
        }

  defstruct [:id, :address, :latitude, :longitude, :description]

  @doc """
  Returns whether the location _might_ be undefined. The API uses (0,0) to
  mark undefined positions, and presumably also a valid origin position.
  Every non-origin position is presumed to be defined.
  """
  @spec is_undefined?(t()) :: boolean()
  def is_undefined?(%__MODULE__{latitude: nil, longitude: nil}), do: true
  def is_undefined?(%__MODULE__{latitude: 0, longitude: 0}), do: true
  def is_undefined?(%__MODULE__{}), do: false

  @doc """
  Convert a JSON map to a structure instance.
  """
  @spec from_json(map()) :: {:ok, t()} | {:error, any()}
  def from_json(data) do
    # TODO: Improve latitude and longitude range validation, coordinates should sit
    # within San Francisco or (0, 0) if undefined.
    with {lat, ""} <- Float.parse(data["latitude"]),
         {lon, ""} <- Float.parse(data["longitude"]),
         {id, ""} <- Integer.parse(data["objectid"]) do
      {:ok,
       %__MODULE__{
         id: id,
         address: data["address"],
         longitude: lon,
         latitude: lat,
         description: data["locationdescription"]
       }}
    else
      err ->
        {:error, err}
    end
  end
end
