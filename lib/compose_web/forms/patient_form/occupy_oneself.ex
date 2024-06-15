defmodule ComposeWeb.PatientForm.OccupyOneSelf do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Legend, only: [values: 0]
  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset
  import ComposeWeb.Gettext

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :reading, :boolean
    field :radio, :boolean
    field :tv, :boolean
    field :note, :string
  end

  def changeset(%__MODULE__{} = section, attrs) do
    section
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
