defmodule Compose.LLM.Prompting do
  alias Compose.LLM.Backend.Ollama

  require Logger

  def execute(config \\ []) do
    config = Keyword.merge(default_config(), config)

    iterations = Keyword.fetch!(config, :iterations)
    models = Keyword.fetch!(config, :models)
    system = Keyword.fetch!(config, :system)
    mode = Keyword.fetch!(config, :mode)
    format = Keyword.fetch!(config, :format)

    rows =
      Enum.flat_map(models, fn {backend, model} ->
        Enum.flat_map(1..iterations, fn iteration ->
          questions()
          |> prompts(mode: mode, format: format)
          |> Enum.with_index()
          |> Enum.map(fn {prompt, index} ->
            prompt = """
            # Instructions
            You are a medical record examiner and responsible for summarizing the state of a patient based on the following report.
            Please read the report carefully and then answer the following question with true or false and give an explanation of your answer.

            If the report does not have enough information to answer the question reply with "insufficient information".

            # Report
            #{patient_report()}

            # Question
            #{prompt}

            # Answer
            """

            {time, result} =
              :timer.tc(fn ->
                backend.generate(%{
                  model: model,
                  stream: false,
                  format: format,
                  system: system,
                  input: prompt
                })
              end)

            result =
              case result do
                {:ok, response} ->
                  Logger.debug(inspect(response, pretty: true, printable_limit: :infinity))
                  %{response: response, error: nil}

                {:error, error} ->
                  Logger.debug(inspect(error, pretty: true, printable_limit: :infinity))
                  %{response: nil, error: error}
              end

            [
              iteration: iteration,
              question_number: index + 1,
              backend: backend |> Atom.to_string() |> String.split(".") |> List.last(),
              model: model,
              prompt: prompt,
              response: result[:response],
              parsed_response: parse_response(result[:response], format),
              error: result[:error],
              duration_in_seconds: time / 1_000_000
            ]
          end)
        end)
      end)

    headers = rows |> List.first() |> Enum.map(fn {key, _} -> Atom.to_string(key) end)
    rows = Enum.map(rows, &Keyword.values/1)
    Compose.CSV.to_file([headers | rows], "prompting.csv")
  end

  def default_config do
    [
      iterations: 10,
      mode: :single,
      format: "",
      system: """
      """,
      models: [
        {Ollama, "mistral:latest"},
        {Ollama, "llama3:latest"},
        {Ollama, "phi3:latest"},
        {Ollama, "gemma:latest"}
      ]
    ]
  end

  def questions do
    [
      "1) What is the patient's first_name?",
      "2) What is the patient's last_name?",
      "3) Does the patient have severe spasticity?",
      "4) Does the patient have a malposition of the extremity?",
      "5) Does the patient have limited resilience due to cardiovascular diseases?",
      "6) Does the patient have behavioral problems with mental illness and dementia?",
      "7) Does the patient have impaired sensory perception?",
      "8) Does the patient have therapy-resistant pain?",
      "9) Does the patient have increased need for care due to body weight?",
      "10) Does the patent have weight/BMI issues?",
      "11) Can the patient walk?",
      "12) Does the patient need instructions to walk?",
      "13) Does the patient need supervision to walk?",
      "14) Does the patient need support to walk?",
      "15) Does the patient need a partial takeover to walk?",
      "16) Does the patient need a complete takeover to walk?",
      "17) What remarks have been made regarding the patient's walking?"
    ]
  end

  def prompts(questions, mode: :accrued, format: format) do
    {_, questions} =
      questions
      |> Enum.reduce({nil, []}, fn
        question, {nil, acc} ->
          {question, [question | acc]}

        question, {previous, acc} ->
          question = previous <> "\n" <> question <> "\n" <> format_instructions(format)
          {question, [question | acc]}
      end)

    questions
    |> Enum.reverse()
    |> Enum.map(&(&1 <> "\n" <> patient_report()))
  end

  def prompts(questions, mode: :single, format: format) do
    Enum.map(questions, &(&1 <> "\n" <> format_instructions(format) <> "\n" <> ""))
  end

  def patient_report do
    """
    """
  end

  defp format_instructions(""), do: ""
  defp format_instructions("json"), do: "Answer concisely and in JSON format."

  defp parse_response(nil, _format), do: nil

  defp parse_response(response, _format = "") do
    response =
      response
      |> String.trim()
      |> String.downcase()

    case response do
      <<"true" <> _rest>> -> true
      <<"false" <> _rest>> -> false
      _ -> response
    end
  end
end
