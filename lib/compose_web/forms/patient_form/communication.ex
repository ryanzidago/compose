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
    field :can_speak, :boolean
    # Lesen
    field :can_read, :boolean
    # Verstehen
    field :can_understand, :boolean
    # Schreiben
    field :can_write, :boolean

    # Blindheit
    field :has_blindness, :boolean
    # Schwerhörigkeit
    field :has_hearing_impairment, :boolean
    # Verwirrtheit
    field :is_confused, :boolean
    # Brille
    field :has_glasses, :boolean
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
