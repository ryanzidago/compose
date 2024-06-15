defmodule ComposeWeb.PatientForm.Attachment do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Legend, only: [values: 0]
  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset
  import ComposeWeb.Gettext

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Mediplan
    field :medication_plan, :boolean
    # Betreuerausweis
    field :carer_id_card, :boolean
    # Wunddokumentation
    field :wound_documentation, :boolean
    # Patientenverfügung
    field :living_will, :boolean
    # Sonstiges
    field :other, :string
    # Telefonische Nachfrage
    field :telephone_enquiry_at, :utc_datetime

    field :note, :string
  end

  def changeset(%__MODULE__{} = section, attrs) do
    section
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
