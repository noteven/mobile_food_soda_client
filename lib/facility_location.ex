defmodule MobileFoodSodaClient.FacilityLocation do
  @moduledoc """
  The WGS84 latitude and longitude of a facility.
  """

  @typedoc """
  WGS84 coordinate.
  """
  @type coordinate() :: number() | nil

  @typedoc """
  Description of the location indicated by the coordinates.
  """
  @type description() :: String.t() | nil

  @type t() :: %__MODULE__{
          longitude: coordinate(),
          latitude: coordinate(),
          description: description()
        }

  defstruct [:latitude, :longitude, :description]

  @doc """
  Returns whether the location _might_ be undefined. The API uses (0,0) to
  mark undefined positions, and presumably also a valid origin position.
  Every non-origin position is presumed to be defined.
  """
  @spec is_undefined?(t()) :: boolean()
  def is_undefined?(%__MODULE__{latitude: nil, longitude: nil}), do: true
  def is_undefined?(%__MODULE__{latitude: 0, longitude: 0}), do: true
  def is_undefined?(%__MODULE__{}), do: false
end
