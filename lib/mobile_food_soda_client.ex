defmodule MobileFoodSodaClient do
  @moduledoc """
  The SF Mobile Food Soda client.
  """
  use Norm

  alias MobileFoodSodaClient.FacilityPermit

  @base_url "https://data.sfgov.org/resource/rqzj-sfat.json"

  @doc """
  Fetches mobile facility permits from the given URL and returns populated
  data instances.
  """
  @spec fetch() :: [FacilityPermit.t()]
  def fetch() do
    Finch.build(:get, @base_url)
    |> Finch.request!(finch_name())
    |> Map.get(:body)
    |> Jason.decode!()

    # |> Enum.reduce([], &json_to_permits/2)
  end

  @spec finch_name(Finch.name()) :: Finch.name()
  defp finch_name(name \\ __MODULE__.Finch) do
    if !Process.whereis(name), do: {:ok, _pid} = Finch.start_link(name: name)

    name
  end

  defp json_map do
    schema(%{
      objectid: spec(is_bitstring()),
      applicant: spec(is_bitstring()),
      facilitytype: spec(is_bitstring()),
      locationdescription: spec(is_bitstring()),
      address: spec(is_bitstring()),
      permit: spec(is_bitstring()),
      status: spec(is_bitstring()),
      fooditems: spec(is_bitstring()),
      latitude: spec(is_bitstring()),
      longitude: spec(is_bitstring()),
      approved: spec(is_bitstring()),
      received: spec(is_bitstring()),
      priorpermit: spec(is_bitstring()),
      expirationdate: spec(is_bitstring())
    })
  end
end
