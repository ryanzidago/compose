defmodule Compose.LLM do
  alias ComposeWeb.PatientForm

  def prompt_modes do
    [:per_form, :per_section, :per_field]
  end

  def generate(%{prompt_mode: :per_form} = params) do
    system = PatientForm.Prompt.base_prompt()

    input =
      Jason.encode!(%{
        locale: params.locale,
        patient_information: params.patient_report,
        form: Jason.encode!(PatientForm.schema())
      })

    result =
      do_generate(%{
        system: system,
        input: input,
        backend: params.backend,
        model: params.model
      })

    with {:ok, response} <- result,
         {:ok, response} <- maybe_parse(response, Map.get(params, :parse_output, false)) do
      {:ok, response}
    else
      {:error, error} -> {:error, error}
    end
  end

  def generate(%{prompt_mode: :per_section} = params) do
    PatientForm.schema()
    |> Map.keys()
    |> Enum.reduce_while({:ok, %{}}, fn section, {:ok, acc} ->
      encoded_schema =
        PatientForm.schema()
        |> Map.get(section)
        |> Jason.encode!()

      system = PatientForm.related(section).prompt(section)

      input =
        Jason.encode!(%{
          locale: Gettext.get_locale(),
          patient_information: params.patient_report,
          form: encoded_schema
        })

      result =
        do_generate(%{
          system: system,
          input: input,
          backend: params.backend,
          model: params.model
        })

      with {:ok, response} <- result,
           {:ok, response} <- maybe_parse(response, Map.get(params, :parse_output, false)) do
        acc = Map.put(acc, Atom.to_string(section), response)
        {:cont, {:ok, acc}}
      else
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  def generate(%{prompt_mode: :per_field} = params) do
    flattened_schema =
      Enum.flat_map(PatientForm.schema(), fn {section, fields} ->
        Enum.map(fields, fn field -> {section, field} end)
      end)

    Enum.reduce_while(flattened_schema, {:ok, %{}}, fn
      {section, {field, type}}, {:ok, acc} ->
        system = PatientForm.related(section).prompt(section, field)

        input =
          Jason.encode!(%{
            locale: Gettext.get_locale(),
            patient_information: params.patient_report,
            form: Jason.encode!(%{field => type})
          })

        result =
          do_generate(%{
            system: system,
            input: input,
            backend: params.backend,
            model: params.model
          })

        with {:ok, response} <- result,
             {:ok, response} <- maybe_parse(response, Map.get(params, :parse_output, false)) do
          acc =
            Map.update(acc, Atom.to_string(section), response, fn section_response ->
              Map.merge(section_response, response)
            end)

          {:cont, {:ok, acc}}
        else
          {:error, error} -> {:halt, {:error, error}}
        end
    end)
  end

  defp do_generate(params) do
    {backend, params} = Map.pop!(params, :backend)
    backend.generate(params)
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

  def maybe_parse(response, _parse = true), do: parse(response)
  def maybe_parse(response, _parse = false), do: {:ok, response}

  # sometimes the LLM returns the response within a map with a key "form"
  def parse(%{"form" => response}), do: parse(response)

  # sometimes the LLM returns a result that needs to be JSON decoded twice!
  def parse(response) when is_binary(response) do
    case Jason.decode(String.trim(response)) do
      {:ok, response} -> parse(response)
      {:error, error} -> {:error, error}
    end
  end

  def parse(%{} = response), do: {:ok, response}
  def parse(response), do: {:error, "Not a map: #{inspect(response)}"}
end
