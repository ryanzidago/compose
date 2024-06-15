defmodule ComposeWeb.PatientForm.Communication do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Legend, only: [values: 0]
  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset
  import ComposeWeb.Gettext

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Sprechen
    field :speaking, :boolean
    # Lesen
    field :reading, :boolean
    # Verstehen
    field :understanding, :boolean
    # Schreiben
    field :writing, :boolean

    # Blindheit
    field :blindness, :boolean
    # Schwerhörigkeit
    field :hearing_impairment, :boolean
    # Verwirrtheit
    field :confusion, :boolean
    # Brille
    field :glasses, :boolean
    # Hörgerät
    field :hearing_aid, Ecto.Enum, values: [:left, :right]
    # Bemerkungen
    field :note, :string
  end

  def changeset(%__MODULE__{} = communication, attrs) do
    communication
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
