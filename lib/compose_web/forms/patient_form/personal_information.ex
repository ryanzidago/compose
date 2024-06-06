defmodule ComposeWeb.PatientForm.PersonalInformation do
  use Ecto.Schema

  import ComposeWeb.PatientForm.Prompt, only: [base_prompt: 0]
  import Ecto.Changeset

  @derive Jason.Encoder
  @primary_key false
  embedded_schema do
    field :first_name, :string
    field :last_name, :string
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
