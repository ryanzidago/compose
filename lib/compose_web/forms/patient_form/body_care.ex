defmodule ComposeWeb.PatientForm.BodyCare do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Legend, only: [values: 0]
  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset
  import ComposeWeb.Gettext

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Baden/Duschen
    field :bathing_and_showering, Ecto.Enum, values: values()
    # Intimpflege
    field :intimate_care, Ecto.Enum, values: values()
    # Oberkörper
    field :upper_body, Ecto.Enum, values: values()
    # Unterkörper
    field :lower_body, Ecto.Enum, values: values()
    # Haarpflege
    field :hair_care, Ecto.Enum, values: values()
    # Nagelpflege
    field :nail_care, Ecto.Enum, values: values()
    # Mundpflge
    field :oral_care, Ecto.Enum, values: values()
    # Rasur
    field :shaving, Ecto.Enum, values: values()
    # An- und Auskleiden
    field :upper_body_dressing_and_undressing, Ecto.Enum, values: values()
    field :lower_body_dressing_and_undressing, Ecto.Enum, values: values()

    # Bemerkungen
    field :note, :string
  end

  def changeset(%__MODULE__{} = body_care, attrs) do
    body_care
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
