defmodule ComposeWeb.PatientForm.Excretion do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Legend, only: [values: 0]
  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset
  import ComposeWeb.Gettext

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # richten der Kleidung
    field :adjusting_clothing, Ecto.Enum, values: values()
    # hygeniesche Nachsorge
    field :hygenic_aftercare, Ecto.Enum, values: values()
    # Stuhlgang
    field :bowel_movement, Ecto.Enum, values: [:normal, :tend_to_diarrhoea, :constipation]
    # stuhl inkontinenz
    field :fecal_incontinence, Ecto.Enum, values: [:yes, :sometimes]
    # Stoma
    field :stoma, Ecto.Enum,
      values: [:colostoma, :lleostoma, :urostoma, :care_by_stoma_therapists]

    # letzter Wechsel / Stuhlgang
    field :last_bowel_movement_at, :utc_datetime

    # Urininkontinenz
    field :urinary_incontinence, Ecto.Enum, values: [:yes, :sometimes]
    # Versorgungsartikel
    field :supply_items, Ecto.Enum, values: [:suprapubic_catheter, :indwelling_catheter]
    field :indwelling_catheter_charriere_number, :float
    # Ableitungssystem gelegt am
    field :discharge_system_placed_at, :utc_datetime
    # Kontinenztraining
    field :has_continence_training, :boolean
    field :note, :string
  end

  def changeset(%__MODULE__{} = section, attrs) do
    section
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
