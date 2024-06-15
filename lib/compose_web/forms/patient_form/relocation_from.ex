defmodule ComposeWeb.PatientForm.RelocationFrom do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Verlegung von
    field :address, :string
    # Kontaktperson
    field :contact_person, :string
    # Telefonnummer
    field :phone_number, :string
    # Fax
    field :fax, :string
  end

  def changeset(%__MODULE__{} = relocation_from, attrs) do
    relocation_from
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
