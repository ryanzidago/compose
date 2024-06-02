defmodule ComposeWeb.PatientForm.Mobility do
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
    field :walking, Ecto.Enum,
      values: [
        :instruction,
        :supervision,
        :support,
        :partial_takeover,
        :complete_takeover
      ]

    field :mobility_note, :string
  end

  def changeset(%__MODULE__{} = mobility, attrs) do
    mobility
    |> cast(attrs, __MODULE__.__schema__(:fields))
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
end
