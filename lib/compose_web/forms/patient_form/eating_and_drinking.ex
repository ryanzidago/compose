defmodule ComposeWeb.PatientForm.EatingAndDrinking do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Legend, only: [values: 0]
  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset
  import ComposeWeb.Gettext

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Hilfe beim Essen
    field :help_with_eating, Ecto.Enum, values: values()
    # Hilfe beim Trinken
    field :help_with_drinking, Ecto.Enum, values: values()
    # Zahnprothese(n)
    field :upper_dentures, :boolean
    field :lower_dentures, :boolean
    # Kauprobleme
    field :chewing_problems, :boolean
    # Schluckprobleme
    field :swallowing_problems, :boolean
    # Schmerzen im Mund
    field :mouth_pain, :boolean
    # Durstgefühl eingeschränkt
    field :thirst_restricted, :boolean
    # Appetit eingeschränkt
    field :appetite_restricted, :boolean
    # Empfohlene Trinkmenge (ml/Tag)
    field :recommended_drinking_amount_in_ml_per_day, :integer
    # Sondentyp
    field :tube_type, :string
    # Sonde gelegt am
    field :tube_inserted_at, :utc_datetime
    # Sondennahrung
    field :tube_nutrition, :string
    # Sondennahrungsmenge (ml)
    field :tube_nutrition_amount_in_ml, :integer
    # Tee (Transnasale Ernährungssonde)
    field :transnasal_feeding_tube, :boolean
    # Tee (menge in ml)
    field :transnasal_feeding_tube_amount_in_ml, :integer
    # Verabreichung
    field :administration_per_injection, :boolean
    field :administration_per_pump, :boolean
    field :administration_per_gravity, :boolean
    # Essen auf Rädern
    field :meals_on_wheels, :boolean
    # Informiert
    field :informed, :boolean
    # Bemerkungen (z.B. Diät, Vorlieben und Abneigungen, Essen auf Rädern)
    field :note, :string
  end

  def changeset(%__MODULE__{} = eating_and_drinking, attrs) do
    eating_and_drinking
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
