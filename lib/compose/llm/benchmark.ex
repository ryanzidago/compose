defmodule Compose.LLM.Benchmark do
  alias Compose.LLM.Backend.Ollama
  alias Compose.LLM.Backend.OpenAI
  alias Compose.LLM.Backend.Perplexity
  alias Compose.LLM.Backend.Mistral

  alias ComposeWeb.PatientForm

  alias Ecto.Changeset

  require Logger

  def execute(config \\ []) do
    config = Keyword.merge(config, default_config())
    :timer.tc(&do_execute/1, [config])
  end

  defp do_execute(config) do
    backends = Keyword.fetch!(config, :backends)
    iterations = Keyword.fetch!(config, :iterations)
    form = Keyword.fetch!(config, :form)
    locale = Keyword.fetch!(config, :locale)
    patient_information = Keyword.fetch!(config, :patient_information)

    Enum.flat_map(backends, fn {backend, models} ->
      Enum.flat_map(models, fn model ->
        Enum.map(1..iterations, fn _ ->
          prompt =
            Jason.encode!(%{
              model: model,
              form: form,
              locale: locale,
              patient_information: patient_information
            })

          response = Compose.LLM.generate!(%{model: model, prompt: prompt}, backend: backend)
          changeset = PatientForm.changeset(%PatientForm{}, response)
          valid? = valid?(changeset)

          %{
            backend: backend,
            model: model,
            response: response,
            valid_changeset: valid?
          }
          |> tap(&Logger.debug/1)
        end)
      end)
    end)
  end

  defp default_config do
    [
      locale: "en",
      patient_information: """
      Today I looked after Mrs. Weber, who has severely limited resilience due to cardiovascular disease,
      suffers from therapy-resistant pain and can no longer walk.

      During the morning care, I carefully washed and dressed her and took care not to aggravate her pain.
      I took particular care when transferring her from bed to wheelchair so as not to overload her circulation.
      During mobilization in the wheelchair, I made sure that she was positioned correctly to prevent further pain.

      Mrs. Weber was patient and cooperative despite her discomfort.
      """,
      form: Jason.encode!(PatientForm.schema()),
      iterations: 10,
      backends: [
        {Ollama, ~w(llama3:latest gemma:latest mistral:latest)}
        # {OpenAI, ~w(gpt-4o gpt-4-turbo gpt-3.5-turbo)},
        # {Perplexity, ~w(llama-3-70b-instruct llama-3-sonar-large-32k-chat)},
        # {Mistral,
        #  ~w(mistral-small-latest mistral-tiny open-mixtral-8x22b open-mixtral-8x7b mistral-large-latest)}
      ]
    ]
  end

  defp valid?(%Changeset{} = changeset) when not changeset.valid?, do: false

  defp valid?(%Changeset{} = changeset) do
    Enum.all?(changeset.changes, fn {_key, %Changeset{} = changeset} ->
      changeset.valid?
    end)
  end
end
