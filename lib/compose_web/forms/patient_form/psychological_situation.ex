defmodule ComposeWeb.PatientForm.PsychologicalSituation do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Legend, only: [values: 0]
  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset
  import ComposeWeb.Gettext

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Bewustseinslage
    field :consciousness_state, Ecto.Enum, values: [:awake, :sleepy]
    # Taggesstruktur
    field :has_daily_structure, :boolean
    # psychische Veränderungen
    field :psychological_changes, :string
    # Motviation und Antrbieb
    # Hypermobilität
    field :is_hyper_mobile, :boolean
    # Unruhezustände
    field :is_restless, :boolean
    # Ängste
    field :has_fear, :boolean
    # depressive Verstimmung
    field :has_depressive_mood, :boolean
    # Ablehnen von Hilfe
    field :refuses_help, :boolean

    # Orientiert
    field :oriented, Ecto.Enum, values: [:yes, :no, :partially]
    # Orientierungsstörung
    field :disorientation, Ecto.Enum, values: [:temporal, :local, :personal]

    # Bemerkungen
    field :note, :string
  end

  def changeset(%__MODULE__{} = psychological_situation, attrs) do
    psychological_situation
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end
end
