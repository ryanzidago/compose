defmodule ComposeWeb.PatientForm.CareRelevantPreExistingConditions do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Pflegerelevante Vorerkrankungen
    field :text, :string
    # Infektionen
    field :infections, :string
    # Letzter Krankenhausaufenthalt; Ort
    field :last_hospital_stay_location, :string
  end

  def changeset(%__MODULE__{} = care_relevant_pre_existing_conditions, attrs) do
    care_relevant_pre_existing_conditions
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
