defmodule Compose.LLM.Benchmark do
  alias ComposeWeb.PatientForm
  alias Compose.LLM.Backend.Ollama
  # I want to run a single prompt in en
  # in per_form, per_section and per_field
  # and measure the time it takes to generate the responses
  # as well as how accurates the responses are
  #
  # later, I want to configure the prompt to activate examples or not
  def execute(config \\ []) do
    config = Keyword.merge(config(), config)

    iterations = Keyword.fetch!(config, :iterations)
    prompt_modes = Keyword.fetch!(config, :prompt_modes)
    models = Keyword.fetch!(config, :models)
    locale = Keyword.fetch!(config, :locale)
    patient_report = Keyword.fetch!(config, :patient_report)

    Enum.flat_map(1..iterations, fn _ ->
      Enum.flat_map(prompt_modes, fn prompt_mode ->
        Enum.map(models, fn {backend, model} ->
          {time, result} =
            :timer.tc(fn ->
              Compose.LLM.generate(
                %{
                  locale: locale,
                  patient_report: patient_report,
                  backend: backend,
                  model: model
                },
                prompt_mode
              )
            end)

          result =
            case result do
              {:ok, response} -> %{response: response, error: nil}
              {:error, error} -> %{response: nil, error: error}
            end

          changeset = PatientForm.changeset(%PatientForm{}, result[:response] || %{})

          %{
            prompt_mode: prompt_mode,
            backend: backend,
            model: model,
            response: result[:response],
            error: result[:error],
            valid?: changeset.valid?,
            duration: time / 1_000_000
          }
        end)
      end)
    end)
  end

  defp config do
    [
      iterations: 10,
      locale: "en",
      prompt_modes: [:per_form, :per_section, :per_field],
      models: [
        {Ollama, "llama3:latest"}
        # {Ollama, "mistral:latest"},
        # {Ollama, "phi3:latest"}
      ],
      patient_report: """
      Today, I cared for Ms. Weber, who has limited physical capacity due to cardiovascular disease, suffers from treatment-resistant pain, and can no longer walk.
      During the morning care routine, I gently assisted her with washing and dressing, being careful not to exacerbate her pain.
      When transferring her from the bed to the wheelchair, I took special precautions to avoid overburdening her cardiovascular system.
      While she was in the wheelchair, I ensured she was correctly positioned to prevent further discomfort. Despite her ailments, Ms. Weber remained patient and cooperative throughout the care process.
      """
    ]
  end
end
