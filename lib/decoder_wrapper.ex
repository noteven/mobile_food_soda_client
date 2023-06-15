defmodule MobileFoodSodaClient.DecoderWrapper do
  @moduledoc """
  Wraps a decoder and encoded data, feeding the encoded data into the decoder
  and converting the decoded output to FacilityPermit values.
  """
  use Norm

  alias ElixirSense.Core.Normalized
  alias MobileFoodSodaClient.MobileFoodFacility
  alias MobileFoodSodaClient.FacilityPermit

  @typedoc """
  A decoding function, accepts an encoded string and a set of options encoded
  as a keyword list. Returns an Enumerable of decoded data.
  """
  @type decoder :: (binary(), Keyword.t() -> Enumerable.t() | binary())


  def decoder_output do
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

  @doc """
  Accepts an encoded binary and a decoder, returns list of parsed permits.
  An optional list of options may be provided that will be sent to the parser
  when parsing.
  """
  @spec decode(binary(), decoder(), Keyword.t()) :: [FacilityPermit.t()]
  def decode(data, decoder, opts) do
    data
    |> decoder.(opts)
    |> Enum.reduce(%{}, &data_to_permit/2)
  end

  @spec data_to_permit(Enumerable.t(), Map.t()) :: Map.t()
  defp data_to_permit(data, acc) do
    %FacilityPermit{
      id: Map.get(:permit),
      applicant: Map.get(:applicant),
      status: Map.get(:status),
      approved_date: Map.get(:approved),
      expiration_date: Map.get(:expirationdate),
      received_date: Map.get(:received),
      facilities: data_to_facility(data)
    }
  end
end
