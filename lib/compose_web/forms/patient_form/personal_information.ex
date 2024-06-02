defmodule ComposeWeb.PatientForm.PersonalInformation do
  use Ecto.Schema

  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :first_name, :string
    field :last_name, :string
  end

  def changeset(%__MODULE__{} = personal_info, attrs) do
    personal_info
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
