defmodule ComposeWeb.PatientForm.AuthorisedRepresentative do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Gesetzlicher Bertreuer
    field :is_legal_guardian, :boolean
    # Bevollmächtigter
    field :is_authorised_representative, :boolean
    field :first_name, :string
    field :last_name, :string
    field :fax_number, :string
    field :email, :string
    # Generalvollmacht
    field :has_general_power_of_attorney, :boolean
    # Patientenverfügung liegt vor
    field :living_will_exists, :boolean
    # Sozialdienst eingeschaltet
    field :social_service_involved, :boolean
    field :social_service_name, :string
    field :social_service_phone_number, :string
    field :valuable_items, Ecto.Enum, values: [:jewelry, :money, :apartment_key, :other]
    field :other_value_items, :string
  end

  def changeset(%__MODULE__{} = representative, attrs) do
    representative
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
