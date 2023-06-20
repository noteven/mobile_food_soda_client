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
          prior_permit: integer(),
          facilities: facilities()
        }

  @enforce_keys [:id, :applicant, :status, :facilities, :received_date]
  defstruct [
    :id,
    :applicant,
    :status,
    :approved_date,
    :expiration_date,
    :received_date,
    :prior_permit,
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

  @doc """
  Check whether status is a valid permit status value.
  """
  defguard valid_status?(status)
           when status in [:requested, :expired, :suspended, :issued, :approved]

  @doc """
  Convert a JSON map to a structure instance.
  """
  @spec from_json(map()) :: {:ok, t()} | {:error, any()}
  def from_json(data) do
    with {:ok, status} <- status_from_json(data),
         {:ok, facility} <- MobileFoodFacility.from_json(data),
         {:ok, received_date} <- received_date(data["received"]),
         {:ok, expiration_date} <- datetime_from_json(data["expirationdate"]),
         {:ok, approved_date} <- datetime_from_json(data["approved"]),
         {prior_permit, ""} <- Integer.parse(data["priorpermit"]) do
      {:ok,
       %__MODULE__{
         id: data["permit"],
         applicant: data["applicant"],
         status: status,
         received_date: received_date,
         approved_date: approved_date,
         expiration_date: expiration_date,
         prior_permit: prior_permit,
         facilities: [facility]
       }}
    else
      err ->
        {:error, err}
    end
  end

  @spec status_from_json(map() | atom()) :: {:ok, status()} | {:error, any()}
  defp status_from_json(%{} = data) do
    with json <- Map.get(data, "status"),
         status_atom <- String.to_existing_atom(String.downcase(String.trim(json))) do
          case status_atom do
            atom when valid_status?(atom) -> {:ok, atom}
            atom -> {:error, "Unknown status #{atom}"}
          end
    else
      err ->
        {:error, err}
    end
  end

  @spec received_date(binary() | nil) :: {:ok, NaiveDateTime.t()} | {:error, any()}
  def received_date(nil), do: {:error, "no received date"}
  def received_date(<<y::32, m::16, d::16>>) do
    {year, ""} = Integer.parse(<<y::32>>)
    {month, ""} = Integer.parse(<<m::16>>)
    {day, ""} = Integer.parse(<<d::16>>)

    NaiveDateTime.from_erl({{year, month, day}, {0, 0, 0}})
  end

  @spec datetime_from_json(String.t() | nil) :: {:ok, NaiveDateTime.t() | nil} | {:error, any()}
  def datetime_from_json(nil), do: {:ok, nil}
  def datetime_from_json(datetime) when is_binary(datetime), do: NaiveDateTime.from_iso8601(datetime)
end
