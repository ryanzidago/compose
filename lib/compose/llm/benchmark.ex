defmodule Compose.LLM.Benchmark do
  alias ComposeWeb.PatientForm

  alias Compose.LLM.Backend.Ollama
  alias Compose.LLM.Backend.OpenAI
  alias Compose.LLM.Backend.Mistral
  alias Compose.LLM.Backend.Perplexity

  def execute(config \\ []) do
    config = Keyword.merge(config(), config)

    iterations = Keyword.fetch!(config, :iterations)
    prompt_modes = Keyword.fetch!(config, :prompt_modes)
    models = Keyword.fetch!(config, :models)
    locale = Keyword.fetch!(config, :locale)
    patient_report = Keyword.fetch!(config, :patient_report)
    parse_output = Keyword.fetch!(config, :parse_output)
    expected = Keyword.fetch!(config, :expected)

    rows =
      Enum.flat_map(models, fn {backend, model} ->
        Enum.flat_map(prompt_modes, fn prompt_mode ->
          Enum.map(1..iterations, fn _iteration ->
            {time, result} =
              :timer.tc(fn ->
                Compose.LLM.generate(%{
                  locale: locale,
                  patient_report: patient_report,
                  backend: backend,
                  model: model,
                  prompt_mode: prompt_mode,
                  parse_output: parse_output
                })
              end)

            result =
              case result do
                {:ok, response} -> %{response: response, error: nil}
                {:error, error} -> %{response: nil, error: error}
              end

            changeset =
              if not is_nil(result[:response]) do
                PatientForm.changeset(%PatientForm{}, result[:response])
              end

            diff = diff(expected, result[:response])

            matches? =
              if not is_nil(diff) do
                Enum.all?(diff, fn {_section_key, section_values} ->
                  Enum.empty?(section_values)
                end)
              else
                false
              end

            [
              prompt_mode: prompt_mode,
              backend: backend(backend),
              model: model,
              response: response(result),
              valid?: valid?(result, changeset),
              valid_count: if(valid?(result, changeset), do: 1, else: 0),
              json_error?: json_error?(result),
              json_error_count: if(json_error?(result), do: 1, else: 0),
              json_error: json_error(result),
              changeset_error?: changeset_error?(changeset),
              changeset_error_count: if(changeset_error?(changeset), do: 1, else: 0),
              changeset: changeset(changeset),
              matches?: matches?,
              matches_count: if(matches?, do: 1, else: 0),
              diff: inspect(diff, pretty: true, printable_limit: :infinity),
              duration_in_seconds: time / 1_000_000
            ]
          end)
        end)
      end)

    headers = rows |> List.first() |> Enum.map(fn {key, _} -> Atom.to_string(key) end)
    rows = Enum.map(rows, &Keyword.values/1)

    Compose.CSV.to_file([headers | rows], "benchmark.csv")
  end

  def test_config do
    Keyword.merge(config(),
      iterations: 1,
      prompt_modes: [:per_form],
      models: [{Ollama, "llama3:latest"}]
    )
  end

  def config do
    [
      iterations: 10,
      locale: "en",
      prompt_modes: [:per_form, :per_section, :per_field],
      parse_output: true,
      models: [
        {Ollama, "llama3:latest"},
        {Ollama, "mistral:latest"},
        {Ollama, "phi3:latest"},
        {Ollama, "gemma:latest"},
        {OpenAI, "gpt-4o"},
        {Mistral, "mistral-large-latest"},
        {Mistral, "open-mixtral-8x22b"},
        {Perplexity, "llama-3-70b-instruct"}
      ],
      patient_report: """
      Today, I cared for Ms. Weber, who has limited physical capacity due to cardiovascular disease, suffers from treatment-resistant pain, and can no longer walk.
      During the morning care routine, I gently assisted her with washing and dressing, being careful not to exacerbate her pain.
      When transferring her from the bed to the wheelchair, I took special precautions to avoid overburdening her cardiovascular system.
      While she was in the wheelchair, I ensured she was correctly positioned to prevent further discomfort. Despite her ailments, Ms. Weber remained patient and cooperative throughout the care process.
      """,
      expected: %{
        "mobility" => %{
          "mobility_note" => nil,
          "walking" => "partial_takeover"
        },
        "personal_information" => %{
          "first_name" => nil,
          "last_name" => "Weber"
        },
        "special_care" => %{
          "therapy_resistant_pain" => true,
          "limited_resilience_due_to_cardiovascular_diseases" => true,
          "malposition_of_the_extremity" => false,
          "severe_spasticity" => false,
          "hemiplegia_and_paresis" => false,
          "behavioral_problems_with_mental_illness_and_dementia" => false,
          "impaired_sensory_perception" => false,
          "increased_need_for_care_due_to_body_weight" => false,
          "weight_bmi" => false
        }
      }
    ]
  end

  defp json_error?(result), do: not is_nil(result[:error])
  defp changeset_error?(nil), do: false
  defp changeset_error?(%Ecto.Changeset{} = changeset), do: not changeset.valid?

  defp json_error(result) do
    case result[:error] do
      %Jason.DecodeError{} = error -> inspect(error, pretty: true, printable_limit: :infinity)
      _ -> ""
    end
  end

  # returns a diff between the expected and actual response
  def diff(_, nil), do: nil

  def diff(%{} = expected, %{} = response) do
    expected_sections = Map.keys(expected)

    Enum.reduce(expected_sections, %{}, fn section, acc ->
      expected_section = Map.get(expected, section)
      actual_section = Map.get(response, section, %{})
      diff = do_diff(expected_section, actual_section)
      Map.put_new(acc, section, diff)
    end)
  end

  def do_diff(%{} = expected, %{} = actual) do
    Enum.reduce(expected, %{}, fn
      {"mobility_note", expected_value}, acc ->
        actual_value = Map.get(actual, "mobility_note", "")

        if String.contains?(actual_value, "walk") do
          acc
        else
          Map.put(acc, "mobility_note", expected: expected_value, actual: actual_value)
        end

      {key, expected_value}, acc ->
        actual_value = Map.get(actual, key)

        actual_value =
          if expected_value in [nil, ""] and actual_value in [nil, ""] do
            nil
          else
            actual_value
          end

        if expected_value != actual_value do
          Map.put(acc, key, expected: expected_value, actual: actual_value)
        else
          acc
        end
    end)
  end

  defp response(nil), do: ""

  defp response(%{} = result) do
    inspect(result[:response], pretty: true, printable_limit: :infinity)
  end

  defp changeset(nil), do: ""

  defp changeset(%Ecto.Changeset{} = changeset) do
    inspect(changeset, pretty: true, printable_limit: :infinity)
  end

  defp valid?(%{} = result, changeset) do
    not json_error?(result) and not changeset_error?(changeset)
  end

  defp backend(module) do
    module
    |> Module.split()
    |> List.last()
    |> String.downcase()
  end
end
