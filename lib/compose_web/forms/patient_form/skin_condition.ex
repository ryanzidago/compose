defmodule ComposeWeb.PatientForm.SkinCondition do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Hautzustand
    field :text, :string
    # Dekubitus (Grad)
    field :decubitus_degree, :integer
    # Dekubitus (Größe)
    field :decubitus_size, :string
    # Ulcus
    field :ulcer, :boolean
    # Ulcus (Größe)
    field :ulcer_size, :string
    # Lokalisation
    field :ulcer_location, :string

    # Pilzinfektion
    field :fungal_infection, :boolean
    # Lokalisation
    field :fungal_infection_location, :string

    # Anlage: Wunddokumentation
    field :wound_documentation, :boolean
  end

  def changeset(%__MODULE__{} = skin_condition, attrs) do
    skin_condition
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
