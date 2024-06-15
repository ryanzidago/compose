defmodule ComposeWeb.PatientForm.ActualMedication do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # siehe Anlage / Entlassungsschein
    field :see_attachment_or_discharge_note, :boolean

    embeds_many :medications, Medication do
      field :name, :string
      field :time, :string
    end

    # Bedarfsmedikation
    embeds_many :medications_as_needed, MedicationAsNeeded do
      field :name, :string
      field :time, :string
    end

    field :last_medication, Ecto.Enum, values: [:morning, :noon, :evening, :night]
    field :time, :utc_datetime
    # letztes BTM-Pflaster
    field :last_btm_patch, :utc_datetime
  end

  def changeset(%__MODULE__{} = actual_medication, attrs) do
    actual_medication
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
