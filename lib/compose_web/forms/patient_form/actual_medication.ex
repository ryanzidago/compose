defmodule ComposeWeb.PatientForm.ActualMedication do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # siehe Anlage / Entlassungsschein
    field :see_attachment_or_discharge_note, :boolean

    embeds_many :medications, Medication, primary_key: false do
      field :name, :string
      field :time, :string
    end

    # Bedarfsmedikation
    embeds_many :medications_as_needed, MedicationAsNeeded, primary_key: false do
      field :name, :string
      field :time, :string
    end

    field :last_medication, Ecto.Enum, values: [:morning, :noon, :evening, :night]
    field :time, :utc_datetime
    # letztes BTM-Pflaster
    field :last_btm_patch_at, :utc_datetime
  end

  def changeset(%__MODULE__{} = actual_medication, attrs) do
    actual_medication
    |> cast(attrs, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embed(:medications, with: &medications_changeset/2)
    |> cast_embed(:medications_as_needed, with: &medications_as_needed_changeset/2)
  end

  def medications_changeset(%__MODULE__.Medication{} = medication, attrs) do
    medication
    |> cast(attrs, [:name, :time])
  end

  def medications_as_needed_changeset(%__MODULE__.MedicationAsNeeded{} = actual_medication, attrs) do
    actual_medication
    |> cast(attrs, [:name, :time])
  end
end
