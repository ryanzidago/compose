defmodule ComposeWeb.PatientForm do
  use Ecto.Schema

  import Ecto.Changeset

  @mobility_values [
    :instruction,
    :supervision,
    :support,
    :partial_takeover,
    :complete_takeover
  ]

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Patienteninformation
    field :first_name, :string
    field :last_name, :string

    # besondere Pflegeprobleme
    field :severe_spasticity, :boolean
    field :severe_spasticity_quoted, :string
    field :hemiplegia_and_paresis, :boolean
    field :hemiplegia_and_paresis_quoted, :string
    field :malposition_of_the_extremity, :boolean
    field :limited_resilience_due_to_cardiovascular_diseases, :boolean
    field :behavioral_problems_with_mental_illness_and_dementia, :boolean
    field :impaired_sensory_perception, :boolean
    field :therapy_resistant_pain, :boolean
    field :increased_need_for_care_due_to_body_weight, :boolean
    field :weight_bmi, :boolean

    # Mobilität
    field :walking, Ecto.Enum, values: @mobility_values
    field :mobility_note, :string

    # Nachweis
    field :datetime, :utc_datetime
    field :signature, :string
  end

  def changeset(patient_form, params \\ %{}) do
    patient_form
    |> cast(params, schema(:fields) -- schema(:embeds))
    |> validate_required([])
  end

  def mobility_values, do: @mobility_values

  def mobility_values_options do
    Enum.map([:none | mobility_values()], fn value ->
      case value do
        :none -> {"Keine", :none}
        :instruction -> {"Anleitung", :instruction}
        :supervision -> {"Überwachung", :supervision}
        :support -> {"Unterstützung", :support}
        :partial_takeover -> {"Teilübernahme", :partial_takeover}
        :complete_takeover -> {"Vollübernahme", :complete_takeover}
      end
    end)
  end

  def schema(key), do: __MODULE__.__schema__(key)

  def schema do
    Map.new(schema(:fields), fn field -> {field, type(field)} end)
  end

  defp type(field) when is_atom(field) do
    # (Ryan) does not work for virtual fields
    case __MODULE__.__schema__(:type, field) do
      {:parameterized, Ecto.Enum, %{mappings: mappings}} -> Keyword.keys(mappings)
      type -> type
    end
  end
end
