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
  @spec fetch() :: [FacilityPermit.t()]
  def fetch do
    Finch.build(:get, @base_url)
    |> Finch.request!(finch_name())
    |> Map.get(:body)
    |> Jason.decode!()
    |> Enum.reduce(%{}, &json_to_permits/2)
  end

  @spec finch_name(Finch.name()) :: Finch.name()
  defp finch_name(name \\ __MODULE__.Finch) do
    if !Process.whereis(name), do: {:ok, _pid} = Finch.start_link(name: name)

    name
  end

  @spec json_to_permits(map(), map()) :: map()
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
end
