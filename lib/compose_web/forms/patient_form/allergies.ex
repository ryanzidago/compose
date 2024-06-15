defmodule ComposeWeb.PatientForm.Allergies do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Allergiepaß
    field :has_allergy_pass, :boolean

    # Allergien
    field :kind, :string
  end

  def changeset(%__MODULE__{} = allergies, attrs) do
    allergies
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
