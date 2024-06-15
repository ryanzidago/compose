defmodule ComposeWeb.PatientForm.TreatingDoctor do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Behandelnder Arzt
    field :name, :string
    # Telefonnummer
    field :phone_number, :string
    # Fax
    field :fax, :string
  end

  def changeset(%__MODULE__{} = treating_doctor, attrs) do
    treating_doctor
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
