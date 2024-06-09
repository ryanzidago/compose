defmodule ComposeWeb.PatientForm.SpecialCare do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :severe_spasticity, :boolean
    field :hemiplegia_and_paresis, :boolean
    field :malposition_of_the_extremity, :boolean
    field :limited_resilience_due_to_cardiovascular_diseases, :boolean
    field :behavioral_problems_with_mental_illness_and_dementia, :boolean
    field :impaired_sensory_perception, :boolean
    field :therapy_resistant_pain, :boolean
    field :increased_need_for_care_due_to_body_weight, :boolean
    field :weight_bmi, :boolean
  end

  def changeset(%__MODULE__{} = special_care, attrs) do
    special_care
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end

  def prompt(:special_care) do
    base_prompt() <>
      """
      Identify the special care needs of the patient in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient has severe spasticity and malposition of the extremity.",
        "form": {
          "severe_spasticity": "boolean",
          "hemiplegia_and_paresis": "boolean",
          "malposition_of_the_extremity": "boolean",
          "limited_resilience_due_to_cardiovascular_diseases": "boolean",
          "behavioral_problems_with_mental_illness_and_dementia": "boolean",
          "impaired_sensory_perception": "boolean",
          "therapy_resistant_pain": "boolean",
          "increased_need_for_care_due_to_body_weight": "boolean",
          "weight_bmi": "boolean"
        }
      }
      ```

      then return:

      ```json
      {
        "severe_spasticity": true,
        "hemiplegia_and_paresis": false,
        "malposition_of_the_extremity": true,
        "limited_resilience_due_to_cardiovascular_diseases": false,
        "behavioral_problems_with_mental_illness_and_dementia": false,
        "impaired_sensory_perception": false,
        "therapy_resistant_pain": false,
        "increased_need_for_care_due_to_body_weight": false,
        "weight_bmi": false
      }
      ```
      """
  end

  def prompt(:special_care, :severe_spasticity) do
    base_prompt() <>
      """
      Identify if the patient has severe spasticity in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient has severe spasticity and malposition of the extremity.",
        "form": {
          "severe_spasticity": "boolean",
        }
      }
      ```

      then return:

      ```json
      {
        "severe_spasticity": true,
      }
      ```
      """
  end

  def prompt(:special_care, :hemiplegia_and_paresis) do
    base_prompt() <>
      """
      Identify if the patient has hemiplegia and paresis in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient has severe spasticity and malposition of the extremity.",
        "form": {
          "hemiplegia_and_paresis": "boolean",
        }
      }
      ```

      then return:

      ```json
      {
        "hemiplegia_and_paresis": false,
      }
      ```
      """
  end

  def prompt(:special_care, :malposition_of_the_extremity) do
    base_prompt() <>
      """
      Identify if the patient has malposition of the extremity in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient has severe spasticity and malposition of the extremity.",
        "form": {
          "malposition_of_the_extremity": "boolean",
        }
      }
      ```

      then return:

      ```json
      {
        "malposition_of_the_extremity": true,
      }
      ```
      """
  end

  def prompt(:special_care, :limited_resilience_due_to_cardiovascular_diseases) do
    base_prompt() <>
      """
      Identify if the patient has limited resilience due to cardiovascular diseases in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient has severe spasticity and malposition of the extremity.",
        "form": {
          "limited_resilience_due_to_cardiovascular_diseases": "boolean",
        }
      }
      ```

      then return:

      ```json
      {
        "limited_resilience_due_to_cardiovascular_diseases": false,
      }
      ```
      """
  end

  def prompt(:special_care, :behavioral_problems_with_mental_illness_and_dementia) do
    base_prompt() <>
      """
      Identify if the patient has behavioral problems with mental illness and dementia in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient has severe spasticity and malposition of the extremity.",
        "form": {
          "behavioral_problems_with_mental_illness_and_dementia": "boolean",
        }
      }
      ```

      then return:

      ```json
      {
        "behavioral_problems_with_mental_illness_and_dementia": false,
      }
      ```
      """
  end

  def prompt(:special_care, :impaired_sensory_perception) do
    base_prompt() <>
      """
      Identify if the patient has impaired sensory perception in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient has severe spasticity and malposition of the extremity.",
        "form": {
          "impaired_sensory_perception": "boolean",
        }
      }
      ```

      then return:

      ```json
      {
        "impaired_sensory_perception": false,
      }
      ```
      """
  end

  def prompt(:special_care, :therapy_resistant_pain) do
    base_prompt() <>
      """
      Identify if the patient has therapy resistant pain in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient has severe spasticity and malposition of the extremity.",
        "form": {
          "therapy_resistant_pain": "boolean",
        }
      }
      ```

      then return:

      ```json
      {
        "therapy_resistant_pain": false,
      }
      ```
      """
  end

  def prompt(:special_care, :increased_need_for_care_due_to_body_weight) do
    base_prompt() <>
      """
      Identify if the patient has increased need for care due to body weight in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient has severe spasticity and malposition of the extremity.",
        "form": {
          "increased_need_for_care_due_to_body_weight": "boolean",
        }
      }
      ```

      then return:

      ```json
      {
        "increased_need_for_care_due_to_body_weight": false,
      }
      ```
      """
  end

  def prompt(:special_care, :weight_bmi) do
    base_prompt() <>
      """
      Identify if the patient has weight BMI in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient has severe spasticity and malposition of the extremity.",
        "form": {
          "weight_bmi": "boolean",
        }
      }
      ```

      then return:

      ```json
      {
        "weight_bmi": false,
      }
      ```
      """
  end
end
