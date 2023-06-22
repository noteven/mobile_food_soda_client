defmodule MobileFoodSodaClient do
  @moduledoc """
  The SF Mobile Food Soda client.
  """
  use Norm

  alias MobileFoodSodaClient.FacilityPermit

  @base_url "https://data.sfgov.org/resource/rqzj-sfat.json"

  @doc """
  Fetches mobile facility permits and returns populated
  data instances.
  """
  @spec fetch(String.t()) :: {:ok, [FacilityPermit.t()]} | {:error, any()}
  def fetch(url \\ @base_url) do
    request =
      Finch.build(:get, url)
      |> Finch.request(finch_name())

    with {:ok, response} <- request,
         {:ok, body} <- Map.fetch(response, :body),
         {:ok, json} <- Jason.decode(body) do
      permits =
        json
        |> Enum.filter(fn permit_json ->
          permit_json
          |> conform(json_map())
          |> elem(0)
          |> Kernel.==(:ok)
        end)
        |> Enum.reduce(%{}, &json_to_permits/2)
        |> Map.values()

      {:ok, permits}
    else
      err ->
        {:error, err}
    end
  end

  @spec finch_name(Finch.name()) :: Finch.name()
  defp finch_name(name \\ __MODULE__.Finch) do
    if !Process.whereis(name), do: {:ok, _pid} = Finch.start_link(name: name)

    name
  end

  @spec json_to_permits(map(), map()) :: map()
  @contract json_to_permits(json_map(), spec(is_map())) :: spec(is_map())
  defp json_to_permits(json_permit, acc) do
    {:ok, permit} = FacilityPermit.from_json(json_permit)
    [facility] = permit.facilities

    case Map.get(json_permit, permit.id) do
      nil ->
        Map.put(acc, permit.id, permit)

      %FacilityPermit{facilities: facilities} = existing_permit ->
        updated_permit = %FacilityPermit{existing_permit | facilities: [facility | facilities]}

        Map.replace(acc, permit.id, updated_permit)
    end
  end

  @spec json_map() :: map()
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
