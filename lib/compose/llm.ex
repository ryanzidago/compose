defmodule Compose.LLM do
  alias ComposeWeb.PatientForm

  def generate(params) do
    {backend, params} = Map.pop!(params, :backend)
    backend.generate(params)
  end

  def generate(params, _prompt_mode = :per_form) do
    system = PatientForm.Prompt.base_prompt()

    input =
      Jason.encode!(%{
        locale: params.locale,
        patient_information: params.patient_report,
        form: Jason.encode!(PatientForm.schema())
      })

    generate(%{
      system: system,
      input: input,
      backend: params.backend,
      model: params.model
    })
  end

  def generate(params, _prompt_mode = :per_section) do
    response =
      PatientForm.schema()
      |> Map.keys()
      |> Map.new(fn section ->
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

        {:ok, response} =
          generate(%{
            system: system,
            input: input,
            backend: params.backend,
            model: params.model
          })

        {Atom.to_string(section), response}
      end)

    {:ok, response}
  end

  def generate(params, _prompt_mode = :per_field) do
    schema = PatientForm.schema()

    response =
      schema
      |> Map.keys()
      |> Map.new(fn section ->
        fields = Map.get(schema, section)

        response =
          Enum.reduce(fields, %{}, fn {field, type}, acc ->
            system = PatientForm.related(section).prompt(section, field)

            input =
              Jason.encode!(%{
                locale: Gettext.get_locale(),
                patient_information: params.patient_report,
                form: Jason.encode!(%{field => type})
              })

            {:ok, response} =
              generate(%{
                system: system,
                input: input,
                backend: params.backend,
                model: params.model
              })

            # flatten the response
            #
            # sometimes the response is within a `form` key
            # response = if is_binary(response), do: Jason.decode!(response), else: response
            # IO.inspect(response)
            response = Map.get(response, "form", response)
            response = if is_binary(response), do: Jason.decode!(response), else: response

            Map.merge(acc, response)
          end)

        {Atom.to_string(section), response}
      end)

    {:ok, response}
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
end
