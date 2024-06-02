defmodule ComposeWeb.PatientForm.Signature do
  use Ecto.Schema

  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :datetime, :utc_datetime
    field :signature, :string
  end

  def changeset(%__MODULE__{} = signature, attrs) do
    signature
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
