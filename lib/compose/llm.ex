defmodule Compose.LLM do
  @stream false
  @system """
  You help nurses fill out forms.

  You will receive a JSON object containing two keys:
  - patient_information: a string that describes the patient state and treatment.
  - form: a JSON object that represents a form to be filled based on the `patient_information`,

  Your goal is to fill out the `form` based on `patient_information`:
  1) Only reply in JSON format, using the `form` that was passed.
  2) Any `string` field should be replied in the given locale.
  3) If no field is mentioned in the `patient_information`, you should reply with the default value for that field. Default values are:
    - `false` for `boolean` fields.
    - `""` for `string` fields.

  For example, if you receive:
  ```json
  {
    "local": "de_DE",
    "patient_information": "Der Patient hat eine hochgradige Spastik aber ich konnte kein Hemiplegien und Paresen feststellen. Er braucht voll Unterstützung bei Gehen, dadurch dass beide Beine nicht mehr bewegt werden können.",
    "form": {
      "severe_spasticity": "boolean",
      "hemiplegia_and_paresis": "boolean",
      "first_name": "string",
      "last_name": "string",
      "walking": ["complete_takeover", "partial_takeover", "independent"],
      "mobility_note": "string"
    }
  }
  ```

  then return:
  ```json
  {
    "first_name": "",
    "last_name": "",
    "severe_spasticity": true,
    "hemiplegia_and_paresis": false,
    "walking": "complete_takeover",
    "mobility_note": "Der Patient kann nicht mehr seine Beine bewegen."
  }
  ```
  """
  def generate!(%{} = body, opts \\ []) do
    body = Map.merge(default_body(), body)

    backend = Keyword.get(opts, :backend, default_backend())

    model =
      if body.model in backend.models() do
        body.model
      else
        backend.default_model()
      end

    body = Map.put(body, :model, model)
    backend.generate!(body)
  end

  def default_body do
    %{system: @system, stream: @stream}
  end

  def module(name) when is_atom(name) do
    name
    |> Atom.to_string()
    |> module()
  end

  def module("openai") do
    Compose.LLM.Backend.OpenAI
  end

  def module(name) when is_binary(name) do
    String.to_existing_atom("Elixir.Compose.LLM.Backend.#{String.capitalize(name)}")
  end

  defp default_backend, do: Application.get_env(:compose, Compose.LLM)[:default_backend]
end
