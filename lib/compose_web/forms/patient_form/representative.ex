defmodule ComposeWeb.PatientForm.Representative do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Angehöriger Verwandtshaftsgrad
    field :degree_of_relationship, :string
    # Vertrauensperson
    field :is_representative, :boolean
    # Informiert?
    field :is_informed, :boolean
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :phone_number_type, Ecto.Enum, values: [:private, :business]
    field :mobile_number, :string
    field :mobile_number_type, Ecto.Enum, values: [:private, :business]
  end

  def changeset(%__MODULE__{} = representative, attrs) do
    representative
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
