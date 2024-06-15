defmodule ComposeWeb.PatientForm.TreatmentCareInstructions do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Behandlungspflegeanweisungen
    field :text, :string
  end

  def changeset(%__MODULE__{} = treatment_care_instructions, attrs) do
    treatment_care_instructions
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
