defmodule ComposeWeb.PatientForm.RestAndSleep do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Legend, only: [values: 0]
  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset
  import ComposeWeb.Gettext

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Einsachlafen
    field :can_fall_asleep, :boolean
    # Durschlafstörungen
    field :sleep_disruptions, Ecto.Enum, values: values()
    # Schlafumkehr
    field :sleep_reversal, Ecto.Enum, values: values()
    # Bemerkungen (z.B. Bett an Wand, freistehend, etc.)
    field :note, :string
  end

  def changeset(%__MODULE__{} = rest_and_sleep, attrs) do
    rest_and_sleep
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
