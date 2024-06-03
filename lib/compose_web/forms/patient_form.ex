defmodule ComposeWeb.PatientForm do
  use Ecto.Schema

  alias ComposeWeb.PatientForm.PersonalInformation
  alias ComposeWeb.PatientForm.SpecialCare
  alias ComposeWeb.PatientForm.Mobility

  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    embeds_one :personal_information, PersonalInformation
    embeds_one :special_care, SpecialCare
    embeds_one :mobility, Mobility
    # embeds_one :signature, Signature
  end

  def changeset(%__MODULE__{} = patient_form, attrs \\ %{}) do
    patient_form
    |> cast(attrs, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embed(:personal_information, with: &PersonalInformation.changeset/2)
    |> cast_embed(:special_care, with: &SpecialCare.changeset/2)
    |> cast_embed(:mobility, with: &Mobility.changeset/2)

    # |> cast_embed(:signature, with: &Signature.changeset/2)
  end

  def schema(module \\ __MODULE__) do
    Map.new(module.__schema__(:fields), fn field ->
      {field, type(module, field)}
    end)
  end

  defp type(module, field) do
    # (Ryan) does not work for virtual fields
    case module.__schema__(:type, field) do
      {:parameterized, Ecto.Enum, %{mappings: mappings}} ->
        Keyword.keys(mappings)

      {:parameterized, Ecto.Embedded, %{related: related}} ->
        schema(related)

      type ->
        type
    end
  end
end
