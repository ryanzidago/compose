defmodule ComposeWeb.PatientForm do
  use Ecto.Schema

  alias ComposeWeb.PatientForm.PersonalInformation
  alias ComposeWeb.PatientForm.Representative
  alias ComposeWeb.PatientForm.AuthorisedRepresentative
  alias ComposeWeb.PatientForm.RelocationFrom
  alias ComposeWeb.PatientForm.RelocationTo
  alias ComposeWeb.PatientForm.TreatingDoctor
  alias ComposeWeb.PatientForm.CareRelevantPreExistingConditions
  alias ComposeWeb.PatientForm.Allergies
  alias ComposeWeb.PatientForm.TreatmentCareInstructions
  alias ComposeWeb.PatientForm.ActualMedication
  alias ComposeWeb.PatientForm.ExistingOrPrescribedMedicalAids
  alias ComposeWeb.PatientForm.SkinCondition
  alias ComposeWeb.PatientForm.SpecialCare
  alias ComposeWeb.PatientForm.Mobility
  alias ComposeWeb.PatientForm.RestAndSleep
  alias ComposeWeb.PatientForm.Breathing
  alias ComposeWeb.PatientForm.Communication
  alias ComposeWeb.PatientForm.EatingAndDrinking
  alias ComposeWeb.PatientForm.BodyCare
  alias ComposeWeb.PatientForm.PsychologicalSituation
  alias ComposeWeb.PatientForm.OccupyOneSelf
  alias ComposeWeb.PatientForm.GenderIdentity
  alias ComposeWeb.PatientForm.Excretion
  alias ComposeWeb.PatientForm.Attachment

  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    embeds_one :personal_information, PersonalInformation
    embeds_one :representative, Representative
    embeds_one :authorised_representative, AuthorisedRepresentative
    embeds_one :relocation_from, RelocationFrom
    embeds_one :relocation_to, RelocationTo
    embeds_one :treating_doctor, TreatingDoctor
    embeds_one :care_relevant_pre_existing_conditions, CareRelevantPreExistingConditions
    embeds_one :allergies, Allergies
    embeds_one :treatment_care_instructions, TreatmentCareInstructions
    embeds_one :actual_medication, ActualMedication
    embeds_one :existing_or_prescribed_medical_aid, ExistingOrPrescribedMedicalAids
    embeds_one :skin_condition, SkinCondition
    embeds_one :special_care, SpecialCare
    embeds_one :mobility, Mobility
    embeds_one :rest_and_sleep, RestAndSleep
    embeds_one :breathing, Breathing
    embeds_one :communication, Communication
    embeds_one :eating_and_drinking, EatingAndDrinking
    embeds_one :body_care, BodyCare
    embeds_one :psychological_situation, PsychologicalSituation
    embeds_one :occupy_one_self, OccupyOneSelf
    embeds_one :gender_identity, GenderIdentity
    embeds_one :excretion, Excretion
    embeds_one :attachment, Attachment
  end

  def changeset(%{} = attrs) do
    changeset(%__MODULE__{}, attrs)
  end

  def changeset(%__MODULE__{} = patient_form, attrs) do
    patient_form
    |> cast(attrs, __MODULE__.__schema__(:fields) -- __MODULE__.__schema__(:embeds))
    |> cast_embed(:personal_information, with: &PersonalInformation.changeset/2)
    |> cast_embed(:representative, with: &Representative.changeset/2)
    |> cast_embed(:authorised_representative, with: &AuthorisedRepresentative.changeset/2)
    |> cast_embed(:relocation_from, with: &RelocationFrom.changeset/2)
    |> cast_embed(:relocation_to, with: &RelocationTo.changeset/2)
    |> cast_embed(:treating_doctor, with: &TreatingDoctor.changeset/2)
    |> cast_embed(:care_relevant_pre_existing_conditions,
      with: &CareRelevantPreExistingConditions.changeset/2
    )
    |> cast_embed(:allergies, with: &Allergies.changeset/2)
    |> cast_embed(:treatment_care_instructions, with: &TreatmentCareInstructions.changeset/2)
    |> cast_embed(:actual_medication, with: &ActualMedication.changeset/2)
    |> cast_embed(:existing_or_prescribed_medical_aid,
      with: &ExistingOrPrescribedMedicalAids.changeset/2
    )
    |> cast_embed(:skin_condition, with: &SkinCondition.changeset/2)
    |> cast_embed(:special_care, with: &SpecialCare.changeset/2)
    |> cast_embed(:mobility, with: &Mobility.changeset/2)
    |> cast_embed(:rest_and_sleep, with: &RestAndSleep.changeset/2)
    |> cast_embed(:breathing, with: &Breathing.changeset/2)
    |> cast_embed(:communication, with: &Communication.changeset/2)
    |> cast_embed(:eating_and_drinking, with: &EatingAndDrinking.changeset/2)
    |> cast_embed(:body_care, with: &BodyCare.changeset/2)
    |> cast_embed(:psychological_situation, with: &PsychologicalSituation.changeset/2)
    |> cast_embed(:occupy_one_self, with: &OccupyOneSelf.changeset/2)
    |> cast_embed(:gender_identity, with: &GenderIdentity.changeset/2)
    |> cast_embed(:excretion, with: &Excretion.changeset/2)
    |> cast_embed(:attachment, with: &Attachment.changeset/2)
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

      {:parameterized, Ecto.Embedded, %{cardinality: :one, related: related}} ->
        schema(related)

      {:parameterized, Ecto.Embedded, %{cardinality: :many, related: related}} ->
        [schema(related)]

      type ->
        type
    end
  end

  def related(section) do
    {:parameterized, Ecto.Embedded, params} = __MODULE__.__schema__(:type, section)
    params.related
  end
end
