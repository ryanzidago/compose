defmodule ComposeWeb.PatientForm.Legend do
  import ComposeWeb.Gettext

  def values do
    [
      :instruction,
      :supervision,
      :support,
      :partial_takeover,
      :complete_takeover
    ]
  end

  def values_options do
    Enum.map([:none | values()], fn value ->
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
end
