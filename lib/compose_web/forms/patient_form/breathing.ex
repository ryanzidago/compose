defmodule ComposeWeb.PatientForm.Breathing do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Legend, only: [values: 0]
  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Atemgeräusche
    field :make_sounds, :boolean
    # Auswurf
    field :has_sputum, :boolean
    # O2-Gerät
    field :has_oxigen_device, :boolean
    # Tracheostoma
    field :has_tracheostomy, :boolean
    # Letzter Wechsel der Kanüle am
    field :last_cannula_change_at, :utc_datetime

    # Bemerkungen (z.B. Rauchen)
    field :note, :string
  end

  def changeset(%__MODULE__{} = breathing, attrs) do
    breathing
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
