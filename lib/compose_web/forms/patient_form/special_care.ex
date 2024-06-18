defmodule ComposeWeb.PatientForm.SpecialCare do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :has_severe_spasticity, :boolean
    field :has_hemiplegia_and_paresis, :boolean
    field :has_malposition_of_the_extremity, :boolean
    field :has_limited_resilience_due_to_cardiovascular_diseases, :boolean
    field :has_behavioral_problems_with_mental_illness_and_dementia, :boolean
    field :has_impaired_sensory_perception, :boolean
    field :has_therapy_resistant_pain, :boolean
    field :has_increased_need_for_care_due_to_body_weight, :boolean
    field :has_weight_bmi_issues, :boolean
  end

  def changeset(%__MODULE__{} = special_care, %{} = attrs) do
    special_care
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end

  # def prompt(:special_care) do
  #   base_prompt() <>
  #     """
  #     Identify the special care needs of the patient in the `patient_information`.

  #     For example if you receive:

  #     ```json
  #     {
  #       "locale": "en",
  #       "patient_information": "The patient has severe spasticity and malposition of the extremity.",
  #       "form": {
  #         "has_severe_spasticity": "boolean",
  #         "has_hemiplegia_and_paresis": "boolean",
  #         "has_malposition_of_the_extremity": "boolean",
  #         "has_limited_resilience_due_to_cardiovascular_diseases": "boolean",
  #         "has_behavioral_problems_with_mental_illness_and_dementia": "boolean",
  #         "has_impaired_sensory_perception": "boolean",
  #         "has_therapy_resistant_pain": "boolean",
  #         "has_increased_need_for_care_due_to_body_weight": "boolean",
  #         "has_weight_bmi_issues": "boolean"
  #       }
  #     }
  #     ```

  #     then return:

  #     ```json
  #     {
  #       "has_severe_spasticity": true,
  #       "has_hemiplegia_and_paresis": false,
  #       "has_malposition_of_the_extremity": true,
  #       "has_limited_resilience_due_to_cardiovascular_diseases": false,
  #       "has_behavioral_problems_with_mental_illness_and_dementia": false,
  #       "has_impaired_sensory_perception": false,
  #       "has_therapy_resistant_pain": false,
  #       "has_increased_need_for_care_due_to_body_weight": false,
  #       "has_weight_bmi_issues": false
  #     }
  #     ```
  #     """
  # end

  # def prompt(:special_care, :has_severe_spasticity) do
  #   base_prompt() <>
  #     """
  #     Identify if the patient has severe spasticity in the `patient_information`.

  #     For example if you receive:

  #     ```json
  #     {
  #       "locale": "en",
  #       "patient_information": "The patient has severe spasticity and malposition of the extremity.",
  #       "form": {
  #         "has_severe_spasticity": "boolean",
  #       }
  #     }
  #     ```

  #     then return:

  #     ```json
  #     {
  #       "has_severe_spasticity": true,
  #     }
  #     ```
  #     """
  # end

  # def prompt(:special_care, :has_hemiplegia_and_paresis) do
  #   base_prompt() <>
  #     """
  #     Identify if the patient has hemiplegia and paresis in the `patient_information`.

  #     For example if you receive:

  #     ```json
  #     {
  #       "locale": "en",
  #       "patient_information": "The patient has severe spasticity and malposition of the extremity.",
  #       "form": {
  #         "has_hemiplegia_and_paresis": "boolean",
  #       }
  #     }
  #     ```

  #     then return:

  #     ```json
  #     {
  #       "has_hemiplegia_and_paresis": false,
  #     }
  #     ```
  #     """
  # end

  # def prompt(:special_care, :has_malposition_of_the_extremity) do
  #   base_prompt() <>
  #     """
  #     Identify if the patient has malposition of the extremity in the `patient_information`.

  #     For example if you receive:

  #     ```json
  #     {
  #       "locale": "en",
  #       "patient_information": "The patient has severe spasticity and malposition of the extremity.",
  #       "form": {
  #         "has_malposition_of_the_extremity": "boolean",
  #       }
  #     }
  #     ```

  #     then return:

  #     ```json
  #     {
  #       "has_malposition_of_the_extremity": true,
  #     }
  #     ```
  #     """
  # end

  # def prompt(:special_care, :has_limited_resilience_due_to_cardiovascular_diseases) do
  #   base_prompt() <>
  #     """
  #     Identify if the patient has limited resilience due to cardiovascular diseases in the `patient_information`.

  #     For example if you receive:

  #     ```json
  #     {
  #       "locale": "en",
  #       "patient_information": "The patient has severe spasticity and malposition of the extremity.",
  #       "form": {
  #         "has_limited_resilience_due_to_cardiovascular_diseases": "boolean",
  #       }
  #     }
  #     ```

  #     then return:

  #     ```json
  #     {
  #       "has_limited_resilience_due_to_cardiovascular_diseases": false,
  #     }
  #     ```
  #     """
  # end

  # def prompt(:special_care, :has_behavioral_problems_with_mental_illness_and_dementia) do
  #   base_prompt() <>
  #     """
  #     Identify if the patient has behavioral problems with mental illness and dementia in the `patient_information`.

  #     For example if you receive:

  #     ```json
  #     {
  #       "locale": "en",
  #       "patient_information": "The patient has severe spasticity and malposition of the extremity.",
  #       "form": {
  #         "has_behavioral_problems_with_mental_illness_and_dementia": "boolean",
  #       }
  #     }
  #     ```

  #     then return:

  #     ```json
  #     {
  #       "has_behavioral_problems_with_mental_illness_and_dementia": false,
  #     }
  #     ```
  #     """
  # end

  # def prompt(:special_care, :has_impaired_sensory_perception) do
  #   base_prompt() <>
  #     """
  #     Identify if the patient has impaired sensory perception in the `patient_information`.

  #     For example if you receive:

  #     ```json
  #     {
  #       "locale": "en",
  #       "patient_information": "The patient has severe spasticity and malposition of the extremity.",
  #       "form": {
  #         "has_impaired_sensory_perception": "boolean",
  #       }
  #     }
  #     ```

  #     then return:

  #     ```json
  #     {
  #       "has_impaired_sensory_perception": false,
  #     }
  #     ```
  #     """
  # end

  # def prompt(:special_care, :has_therapy_resistant_pain) do
  #   base_prompt() <>
  #     """
  #     Identify if the patient has therapy resistant pain in the `patient_information`.

  #     For example if you receive:

  #     ```json
  #     {
  #       "locale": "en",
  #       "patient_information": "The patient has severe spasticity and malposition of the extremity.",
  #       "form": {
  #         "has_therapy_resistant_pain": "boolean",
  #       }
  #     }
  #     ```

  #     then return:

  #     ```json
  #     {
  #       "has_therapy_resistant_pain": false,
  #     }
  #     ```
  #     """
  # end

  # def prompt(:special_care, :has_increased_need_for_care_due_to_body_weight) do
  #   base_prompt() <>
  #     """
  #     Identify if the patient has increased need for care due to body weight in the `patient_information`.

  #     For example if you receive:

  #     ```json
  #     {
  #       "locale": "en",
  #       "patient_information": "The patient has severe spasticity and malposition of the extremity.",
  #       "form": {
  #         "has_increased_need_for_care_due_to_body_weight": "boolean",
  #       }
  #     }
  #     ```

  #     then return:

  #     ```json
  #     {
  #       "has_increased_need_for_care_due_to_body_weight": false,
  #     }
  #     ```
  #     """
  # end

  # def prompt(:special_care, :has_weight_bmi_issues) do
  #   base_prompt() <>
  #     """
  #     Identify if the patient has weight BMI in the `patient_information`.

  #     For example if you receive:

  #     ```json
  #     {
  #       "locale": "en",
  #       "patient_information": "The patient has severe spasticity and malposition of the extremity.",
  #       "form": {
  #         "has_weight_bmi_issues": "boolean",
  #       }
  #     }
  #     ```

  #     then return:

  #     ```json
  #     {
  #       "has_weight_bmi_issues": false,
  #     }
  #     ```
  #     """
  # end
end
