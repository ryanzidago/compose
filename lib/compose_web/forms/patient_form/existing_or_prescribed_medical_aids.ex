defmodule ComposeWeb.PatientForm.ExistingOrPrescribedMedicalAids do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Vorhandene oder verordnete Hilfsmittel
    field :text, :string
  end

  def changeset(%__MODULE__{} = existing_or_prescribed_medical_aids, attrs) do
    existing_or_prescribed_medical_aids
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
