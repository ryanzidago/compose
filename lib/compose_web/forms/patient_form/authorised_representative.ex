defmodule ComposeWeb.PatientForm.AuthorisedRepresentative do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset
  import ComposeWeb.Gettext

  @valuable_items [:jewelry, :money, :apartment_key, :other]

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
    field :valuable_items, {:array, :string}
    field :other_value_items, :string
  end

  def changeset(%__MODULE__{} = representative, attrs) do
    representative
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_subset(:valuable_items, Enum.map(valuable_items(), &Atom.to_string/1))
  end

  def valuable_items, do: @valuable_items
end
