defmodule Compose.LLM do
  require Logger

  @endpoint "http://localhost:11434/api"
  @model "llama3:latest"
  @format "json"
  @stream false

  # ask the AI to always quote itself
  @system """
  You help German nurses fill out forms.

  You will receive a JSON object representing the form:

  # {Jason.encode!(ComposeWeb.PatientForm.schema())}

  as well as free text that describes the patient state and treatment.

  Your goal is to fill out the JSON based on the information from the free text.
  - Only reply in JSON format, using the same JSON that was passed.
  - Any `string` field should be replied in German.

  For example, if the free text says:

  ```text
  Der Patient hat eine hochgradige Spastik aber ich konnte kein Hemiplegien und Paresen feststellen.
  Er braucht voll Unterstützung bei Gehen, dadurch dass beide Beine nicht mehr bewegt werden können.
  ```

  then return:

  ```json
  {
    "severe_spasticity": true,
    "hemiplegia_and_paresis": false,
    "walking": "complete_takeover",
    "walking_quoted": "Er braucht voll Unterstützung bei Gehen.",
    "mobility_note": "Der Patient kann nicht mehr seine Beine bewegen."
  }
  ```
  """
  @headers [{"content-type", "application/json"}]
  @default_options receive_timeout: 1_000_000 * 60 * 60,
                   pool_timeout: 1_000_000 * 60 * 60,
                   request_timeout: 1_000_000 * 60 * 60

  def generate!(%{} = body) do
    body =
      default_body()
      |> Map.merge(body)
      |> Jason.encode!()

    Logger.debug("input body: #{inspect(body)}")

    response =
      :post
      |> Finch.build(@endpoint <> "/generate", @headers, body)
      |> Finch.request!(Compose.Finch, @default_options)

    body =
      response.body
      |> Jason.decode!()
      |> Map.get("response")
      |> Jason.decode!()

    Logger.debug("output body: #{inspect(body)}")

    body
  end

  def tags do
    response =
      :get
      |> Finch.build(@endpoint <> "/tags", @headers)
      |> Finch.request!(Compose.Finch, @default_options)

    body = Jason.decode!(response.body)

    body
    |> Map.get("models", [])
    |> Enum.map(fn model -> model["name"] end)
    |> Enum.sort()
  end

  defp default_body do
    %{
      model: @model,
      system: @system,
      format: @format,
      stream: @stream
    }
  end
end
