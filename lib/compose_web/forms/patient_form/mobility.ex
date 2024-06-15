defmodule ComposeWeb.PatientForm.Mobility do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Legend, only: [values: 0]
  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset
  import ComposeWeb.Gettext

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    # Gehen
    field :walking, Ecto.Enum, values: values()
    # Stehen
    field :standing, Ecto.Enum, values: values()
    # Sitzen
    field :sitting, Ecto.Enum, values: values()
    # Bewegen im Bett
    field :moving_in_bed, Ecto.Enum, values: values()
    # Hinsetzen
    field :sitting_down, Ecto.Enum, values: values()
    # Hinlegen
    field :laying, Ecto.Enum, values: values()

    field :aids, :string
    field :note, :string
  end

  def changeset(%__MODULE__{} = mobility, attrs) do
    mobility
    |> cast(attrs, __MODULE__.__schema__(:fields))
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
          "walking": #{inspect(values())},
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
      ```
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
          "walking": #{inspect(values())},
        }
      }
      ```

      then return:

      ```json
      {
        "walking": "support",
      }
      ```
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
      ```
      """
  end
end
