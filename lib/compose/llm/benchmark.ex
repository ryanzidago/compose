defmodule Compose.LLM.Benchmark do
  alias ComposeWeb.PatientForm
  alias Compose.LLM.Backend.Ollama

  def execute(config \\ []) do
    config = Keyword.merge(config(), config)

    iterations = Keyword.fetch!(config, :iterations)
    prompt_modes = Keyword.fetch!(config, :prompt_modes)
    models = Keyword.fetch!(config, :models)
    locale = Keyword.fetch!(config, :locale)
    patient_report = Keyword.fetch!(config, :patient_report)
    parse_output = Keyword.fetch!(config, :parse_output)

    rows =
      Enum.flat_map(1..iterations, fn _iteration ->
        Enum.flat_map(models, fn {backend, model} ->
          Enum.map(prompt_modes, fn prompt_mode ->
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

            [
              prompt_mode: prompt_mode,
              backend: backend(backend),
              model: model,
              response:
                inspect(result[:response] || "", pretty: true, printable_limit: :infinity),
              error?: json_error?(result) or changeset_error?(changeset),
              json_error?: json_error?(result),
              json_error: json_error(result),
              changeset_error?: changeset_error?(changeset),
              changeset: inspect(changeset || "", pretty: true, printable_limit: :infinity),
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
        {Ollama, "gemma:latest"}
      ],
      patient_report: """
      Today, I cared for Ms. Weber, who has limited physical capacity due to cardiovascular disease, suffers from treatment-resistant pain, and can no longer walk.
      During the morning care routine, I gently assisted her with washing and dressing, being careful not to exacerbate her pain.
      When transferring her from the bed to the wheelchair, I took special precautions to avoid overburdening her cardiovascular system.
      While she was in the wheelchair, I ensured she was correctly positioned to prevent further discomfort. Despite her ailments, Ms. Weber remained patient and cooperative throughout the care process.
      """
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

  defp backend(module) do
    module
    |> Module.split()
    |> List.last()
    |> String.downcase()
  end
end
