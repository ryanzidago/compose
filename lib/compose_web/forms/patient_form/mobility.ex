defmodule ComposeWeb.PatientForm.Mobility do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset
  import ComposeWeb.Gettext

  @mobility_values [
    :instruction,
    :supervision,
    :support,
    :partial_takeover,
    :complete_takeover
  ]

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :walking, Ecto.Enum,
      values: [
        :instruction,
        :supervision,
        :support,
        :partial_takeover,
        :complete_takeover
      ]

    field :mobility_note, :string
  end

  def changeset(%__MODULE__{} = mobility, attrs) do
    mobility
    |> cast(attrs, __MODULE__.__schema__(:fields))
  end

  def mobility_values, do: @mobility_values

  def mobility_values_options do
    Enum.map([:none | mobility_values()], fn value ->
      case value do
        :none -> {dgettext("patient_form", "None"), :none}
        :instruction -> {dgettext("patient_form", "Instruction"), :instruction}
        :supervision -> {dgettext("patient_form", "Supervision"), :supervision}
        :support -> {dgettext("patient_form", "Support"), :support}
        :partial_takeover -> {dgettext("patient_form", "Partial Takeover"), :partial_takeover}
        :complete_takeover -> {dgettext("patient_form", "Complete Takeover"), :complete_takeover}
      end
    end)
  end

  def prompt(:mobility) do
    base_prompt() <>
      """
      Identify the mobility situation of the patient in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient needs support when walking.",
        "form": {
          "walking": #{@mobility_values},
          "mobility_note": "string"
        }
      }
      ```

      then return:

      ```json
      {
        "walking": "support",
        "mobility_note": "The patient needs support when walking."
      }
      """
  end

  def prompt(:mobility, :walking) do
    base_prompt() <>
      """
      Identify the walking situation of the patient in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient needs support when walking.",
        "form": {
          "walking": #{inspect(@mobility_values)},
        }
      }
      ```

      then return:

      ```json
      {
        "walking": "support",
      }
      """
  end

  def prompt(:mobility, :mobility_note) do
    base_prompt() <>
      """
      Identify the mobility note of the patient in the `patient_information`.

      For example if you receive:

      ```json
      {
        "locale": "en",
        "patient_information": "The patient needs support when walking.",
        "form": {
          "mobility_note": "string"
        }
      }
      ```

      then return:

      ```json
      {
        "mobility_note": "The patient needs support when walking."
      }
      """
  end
end
