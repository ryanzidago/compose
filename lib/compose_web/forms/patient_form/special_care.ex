defmodule ComposeWeb.PatientForm.SpecialCare do
  use Ecto.Schema

  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :severe_spasticity, :boolean
    field :hemiplegia_and_paresis, :boolean
    field :malposition_of_the_extremity, :boolean
    field :limited_resilience_due_to_cardiovascular_diseases, :boolean
    field :behavioral_problems_with_mental_illness_and_dementia, :boolean
    field :impaired_sensory_perception, :boolean
    field :therapy_resistant_pain, :boolean
    field :increased_need_for_care_due_to_body_weight, :boolean
    field :weight_bmi, :boolean
  end

  def changeset(%__MODULE__{} = special_care, attrs) do
    special_care
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
