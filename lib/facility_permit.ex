defmodule MobileFoodSodaClient.FacilityPermit do
  @moduledoc """
  A mobile food facilities permit data

  NOTE: A permit will alway have a received date, but due to unsanitary
  data it may not have an approved date and/or expiration date.
  """

  alias MobileFoodSodaClient.MobileFoodFacility

  @typedoc """
  Permit identifier, eg: 22MFF-00036.
  """
  @type id() :: String.t()

  @typedoc """
  Name of the applicant, this can be the name of an individual or business.
  """
  @type applicant() :: String.t()
  @type status() :: :requested | :expired | :suspended | :issued | :approved
  @type received_date :: NaiveDateTime.t()
  @type approved_date :: NaiveDateTime.t() | nil
  @type expiration_date :: NaiveDateTime.t() | nil
  @type facilities :: [MobileFoodFacility.t()]

  @type t() :: %__MODULE__{
          id: id(),
          applicant: applicant(),
          status: status(),
          received_date: received_date(),
          approved_date: approved_date(),
          expiration_date: expiration_date(),
          facilities: facilities()
        }

  @enforce_keys [:id, :applicant, :status, :facilities]
  defstruct [
    :id,
    :applicant,
    :status,
    :approved_date,
    :expiration_date,
    :received_date,
    :facilities
  ]

  @doc """
  Returns true if the permit has expired, or status is expired, false otherwise.

    iex> alias MobileFoodSodaClient.FacilityPermit
    ...> FacilityPermit.is_expired?(%FacilityPermit{expiration_date: ~N[2010-04-17 14:00:00]})
    true

    iex> FacilityPermit.is_expired?(%FacilityPermit{})
    false
  """
  @spec is_expired?(t()) :: boolean()
  def is_expired?(%__MODULE__{status: :expired}), do: true

  def is_expired?(%__MODULE__{expiration_date: date}),
    do: NaiveDateTime.diff(NaiveDateTime.utc_now(), date) > 0

  def is_expired?(%__MODULE__{}), do: false
end
