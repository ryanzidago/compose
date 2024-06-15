defmodule ComposeWeb.PatientForm.PersonalInformation do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :first_name, :string
    field :last_name, :string
    # Adresse
    field :address, :string
    # Geburtsdatum
    field :birth_date, :date
    # Personalausweis
    field :id_card, :boolean
    # Zusatzversicherung
    field :additional_insurance, :boolean
    # krankenversichertenkarte
    field :health_insurance_card, :boolean
    # Zuzahlungsbefreiung
    field :exmption_from_co_payment, :boolean
    # Religion
    field :religion, :string
    # Muttersprache
    field :mother_tongue, :string

    # Pflegestufe bewilligt
    field :care_level_approved, Ecto.Enum,
      values: [:"0", :"1", :"2", :"3", :hard_case, :expedited_procedure]

    # Pflegestufe beantragt am
    field :care_level_requested_at, :utc_datetime
    # Absatz 37 Abs. 1 (SGB V) Genehmigt bis
    field :paragraph_37_section_1_approved_until, :utc_datetime
    # Absatz 37 Abs. 2 (SGB V) Genehmigt bis
    field :paragraph_37_section_2_approved_until, :utc_datetime
    # Absatz 37b (SGB V) Genehmigt bis
    field :paragraph_37b_approved_until, :utc_datetime
    # Absatz 42 (SGB XI) Genehmigt bis
    field :paragraph_42_approved_until, :utc_datetime
  end

  def changeset(%__MODULE__{} = personal_info, attrs) do
    personal_info
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end

  def prompt(:personal_information) do
    base_prompt() <>
      """
      Identify the first name and last name of the patient in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "de_DE",
        "patient_information": "Martin Bäker ist leider krank und kann nicht mehr laufen.",
        "form": {
          "first_name": "string",
          "last_name": "string",
        }
      }
      ```

      then return:

      ```json
      {
        "first_name": "Martin",
        "last_name": "Bäker",
      }
      ```
      """
  end

  def prompt(:personal_information, :first_name) do
    base_prompt() <>
      """
      Identify the first name of the patient in the `patient_information`.

      For example, if you receive:

      ```json
      {
        "locale": "de_DE",
        "patient_information": "Martin Bäker ist leider krank und kann nicht mehr laufen.",
        "form": {
          "first_name": "string",
        }
      }
      ```

      then return:

      ```json
      {
        "first_name": "Martin",
      }
      ```
      """
  end

  def prompt(:personal_information, :last_name) do
    base_prompt() <>
      """
      Identify the last name of the patient in the `patient_information`.

      For example, if you receive:

      ```json
      {
        "locale": "de_DE",
        "patient_information": "Martin Bäker ist leider krank und kann nicht mehr laufen.",
        "form": {
          "last_name": "string",
        }
      }
      ```

      then return:

      ```json
      {
        "last_name": "Bäker",
      }
      ```
      """
  end
end
