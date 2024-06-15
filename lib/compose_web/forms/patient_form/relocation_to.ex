defmodule ComposeWeb.PatientForm.RelocationTo do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Verlegung nach
    field :address, :string
    # Hause
    field :is_home, :boolean
    # Kontaktperson
    field :contact_person, :string
    # Telefonnummer
    field :phone_number, :string
    # Fax
    field :fax, :string
  end

  def changeset(%__MODULE__{} = relocation_to, attrs) do
    relocation_to
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
