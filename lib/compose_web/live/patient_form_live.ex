defmodule ComposeWeb.PatientFormLive do
  use ComposeWeb, :live_view

  alias ComposeWeb.PatientForm
  alias Phoenix.LiveView

  require Logger

  @impl LiveView
  def mount(%{"locale" => locale}, _session, socket) do
    Gettext.put_locale(locale)

    socket =
      socket
      |> assign_async(:changeset, fn ->
        {:ok, %{changeset: PatientForm.changeset(%{})}}
      end)
      |> assign_async(:response, fn -> {:ok, %{response: nil}} end)
      |> assign_async(:error, fn -> {:ok, %{error: nil}} end)
      |> assign(patient_report: nil)
      |> assign_backend_config()
      |> assign(locales: ~w(en de_DE))
      |> assign(locale: locale)
      |> assign(prompt_modes: Compose.LLM.prompt_modes())
      |> assign(prompt_mode: :per_form)

    {:ok, socket}
  end

  defp assign_backend_config(socket) do
    backends = backends()

    {_label, backend} =
      Enum.find(backends, fn {_label, module} ->
        module == Application.get_env(:compose, Compose.LLM)[:default_backend]
      end)

    models = backend.models()
    model = backend.default_model()

    socket
    |> assign(backends: backends)
    |> assign(backend: backend)
    |> assign(models: models)
    |> assign(model: model)
  end

  defp backends do
    Application.get_env(:compose, Compose.LLM)
    |> Keyword.get(:backends, [])
    |> Enum.sort()
    |> Enum.map(fn {backend, _} ->
      backend = Compose.LLM.module(backend)
      {backend.name, backend}
    end)
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
      <div class="grid grid-cols-6 gap-20">
        <div class="col-span-1">
          <div class="w-24">
            <.form for={%{}} phx-change="change_locale" as={:locale}>
              <.input
                type="select"
                name="locale"
                label={dgettext("patient_form", "Locale")}
                value={@locale}
                options={@locales}
              />
            </.form>
          </div>
        </div>
        <.form
          for={%{}}
          phx-change="change_patient_report"
          phx-submit="submit_patient_report"
          class="col-span-2 flex flex-col gap-8"
        >
          <div class="flex flex-col gap-2">
            <.input
              type="textarea"
              value={@patient_report}
              name="patient_report"
              label={
                dgettext("patient_form", "Write the text that contains the patient information here.")
              }
              class="min-h-screen"
            />
            <.input type="select" name="backend" label="Backend" value={@backend} options={@backends} />
            <.input type="select" name="model" label="Model" value={@model} options={@models} />
            <.input
              type="select"
              name="prompt_mode"
              label="Prompt Mode"
              value={@prompt_mode}
              options={@prompt_modes}
            />
          </div>
          <.button :if={!@response.loading}><%= dgettext("patient_form", "Send") %></.button>
          <.button :if={@response.loading} class="opacity-80 cursor-progress">
            <%= dgettext("patient_form", "Loading") %>
          </.button>
          <div :if={@response.result} class="text-xs w-96 overflow-x-auto">
            <h2><%= dgettext("patient_form", "Response") %></h2>
            <pre class="w-90"><%= Jason.encode!(@response.result || "", pretty: true) %></pre>
          </div>
          <div :if={@error.result} class="text-xs w-96 overflow-x-auto">
            <h2><%= dgettext("patient_form", "Error") %></h2>
            <pre class="w-90"><%= inspect(@error, pretty: true) %></pre>
          </div>
        </.form>

        <.form
          :let={f}
          for={@changeset.result}
          class="max-h-screen overflow-x-auto col-span-2 flex flex-col gap-20"
          as={:patient_form}
        >
          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Patient information") %></h1>
            <.inputs_for
              :let={information}
              field={f[:personal_information]}
              as={:personal_information}
            >
              <div class="flex flex-col gap-2">
                <.input
                  type="text"
                  field={information[:first_name]}
                  label={dgettext("patient_form", "First name")}
                />
                <.input
                  type="text"
                  field={information[:last_name]}
                  label={dgettext("patient_form", "Last name")}
                />
                <.input
                  type="text"
                  field={information[:address]}
                  label={dgettext("patient_form", "Address")}
                />
                <.input
                  type="date"
                  field={information[:birth_date]}
                  label={dgettext("patient_form", "Date of birth")}
                />
                <.input
                  type="checkbox"
                  field={information[:id_card]}
                  label={dgettext("patient_form", "ID card")}
                />
                <.input
                  type="checkbox"
                  field={information[:additional_insurance]}
                  label={dgettext("patient_form", "Additional insurance")}
                />
                <.input
                  type="checkbox"
                  field={information[:health_insurance_card]}
                  label={dgettext("patient_form", "Health insurance card")}
                />
                <.input
                  type="checkbox"
                  field={information[:exmption_from_co_payment]}
                  label={dgettext("patient_form", "Exemption from co-payment")}
                />
                <.input
                  type="text"
                  field={information[:religion]}
                  label={dgettext("patient_form", "Religion")}
                />
                <.input
                  type="text"
                  field={information[:mother_tongue]}
                  label={dgettext("patient_form", "Mother tongue")}
                />
                <.input
                  type="select"
                  field={information[:care_level_approved]}
                  label={dgettext("patient_form", "Care level approved")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={
                    Ecto.Enum.mappings(
                      ComposeWeb.PatientForm.PersonalInformation,
                      :care_level_approved
                    )
                  }
                />
                <.input
                  type="datetime-local"
                  field={information[:care_level_requested_at]}
                  label={dgettext("patient_form", "Care level requested at")}
                />
                <.input
                  type="datetime-local"
                  field={information[:paragraph_37_section_1_approved_until]}
                  label={dgettext("patient_form", "Paragraph 37 Section 1 approved until")}
                />
                <.input
                  type="datetime-local"
                  field={information[:paragraph_37_section_2_approved_until]}
                  label={dgettext("patient_form", "Paragraph 37 Section 2 approved until")}
                />
                <.input
                  type="datetime-local"
                  field={information[:paragraph_37b_approved_until]}
                  label={dgettext("patient_form", "Paragraph 37b approved until")}
                />
                <.input
                  type="datetime-local"
                  field={information[:paragraph_42_approved_until]}
                  label={dgettext("patient_form", "Paragraph 42 approved until")}
                />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Representative") %></h1>
            <.inputs_for :let={representative} field={f[:representative]} as={:representative}>
              <div class="flex flex-col gap-2">
                <.input
                  type="text"
                  field={representative[:degree_of_relationship]}
                  label={dgettext("patient_form", "Degree of relationship")}
                />
                <.input
                  type="checkbox"
                  field={representative[:representative]}
                  label={dgettext("patient_form", "Representative")}
                />
                <.input
                  type="checkbox"
                  field={representative[:informed]}
                  label={dgettext("patient_form", "Informed")}
                />
                <.input
                  type="text"
                  field={representative[:first_name]}
                  label={dgettext("patient_form", "Representative first name")}
                />
                <.input
                  type="text"
                  field={representative[:last_name]}
                  label={dgettext("patient_form", "Representative last name")}
                />
                <.input
                  type="text"
                  field={representative[:phone_number]}
                  label={dgettext("patient_form", "Representative phone number")}
                />
                <.input
                  type="select"
                  field={representative[:phone_number_type]}
                  label={dgettext("patient_form", "Representative phone number type")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={
                    Ecto.Enum.mappings(ComposeWeb.PatientForm.Representative, :phone_number_type)
                  }
                />
                <.input
                  type="text"
                  field={representative[:mobile_number]}
                  label={dgettext("patient_form", "Representative mobile number")}
                />
                <.input
                  type="select"
                  field={representative[:mobile_number_type]}
                  label={dgettext("patient_form", "Representative mobile number type")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={
                    Ecto.Enum.mappings(ComposeWeb.PatientForm.Representative, :mobile_number_type)
                  }
                />
              </div>
            </.inputs_for>
          </section>
          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Authorised representative") %></h1>
            <.inputs_for
              :let={authorised_representative}
              field={f[:authorised_representative]}
              as={:authorised_representative}
            >
              <div class="flex flex-col gap-2">
                <.input
                  type="checkbox"
                  field={authorised_representative[:legal_guardian]}
                  label={dgettext("patient_form", "Legal guardian")}
                />
                <.input
                  type="checkbox"
                  field={authorised_representative[:authorised_representative]}
                  label={dgettext("patient_form", "Authorised representative")}
                />
                <.input
                  type="text"
                  field={authorised_representative[:first_name]}
                  label={dgettext("patient_form", "Authorised representative first name")}
                />
                <.input
                  type="text"
                  field={authorised_representative[:last_name]}
                  label={dgettext("patient_form", "Authorised representative last name")}
                />
                <.input
                  type="text"
                  field={authorised_representative[:fax_number]}
                  label={dgettext("patient_form", "Authorised representative fax number")}
                />
                <.input
                  type="email"
                  field={authorised_representative[:email]}
                  label={dgettext("patient_form", "Authorised representative email")}
                />
                <.input
                  type="checkbox"
                  field={authorised_representative[:general_power_of_attorney]}
                  label={dgettext("patient_form", "General power of attorney")}
                />
                <.input
                  type="checkbox"
                  field={authorised_representative[:living_will_exists]}
                  label={dgettext("patient_form", "Living will exists")}
                />
                <.input
                  type="checkbox"
                  field={authorised_representative[:social_service_involved]}
                  label={dgettext("patient_form", "Social service involved")}
                />
                <.input
                  type="text"
                  field={authorised_representative[:social_service_name]}
                  label={dgettext("patient_form", "Social service name")}
                />
                <.input
                  type="text"
                  field={authorised_representative[:social_service_phone_number]}
                  label={dgettext("patient_form", "Social service phone number")}
                />
                <.input
                  type="select"
                  field={authorised_representative[:valuable_items]}
                  label={dgettext("patient_form", "Valuable items")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={
                    Ecto.Enum.mappings(
                      ComposeWeb.PatientForm.AuthorisedRepresentative,
                      :valuable_items
                    )
                  }
                />
                <.input
                  type="text"
                  field={authorised_representative[:other_value_items]}
                  label={dgettext("patient_form", "Other value items")}
                />
              </div>
            </.inputs_for>
          </section>
          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Relocation from") %></h1>
            <.inputs_for :let={relocation_from} field={f[:relocation_from]} as={:relocation_from}>
              <div class="flex flex-col gap-2">
                <.input
                  type="text"
                  field={relocation_from[:address]}
                  label={dgettext("patient_form", "Relocation from")}
                />
                <.input
                  type="text"
                  field={relocation_from[:contact_person]}
                  label={dgettext("patient_form", "Contact person")}
                />
                <.input
                  type="text"
                  field={relocation_from[:phone_number]}
                  label={dgettext("patient_form", "Phone number")}
                />
                <.input
                  type="text"
                  field={relocation_from[:fax]}
                  label={dgettext("patient_form", "Fax")}
                />
              </div>
            </.inputs_for>
          </section>
          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Relocation to") %></h1>
            <.inputs_for :let={relocation_to} field={f[:relocation_to]} as={:relocation_to}>
              <div class="flex flex-col gap-2">
                <.input
                  type="text"
                  field={relocation_to[:address]}
                  label={dgettext("patient_form", "Relocation to")}
                />
                <.input
                  type="checkbox"
                  field={relocation_to[:home]}
                  label={dgettext("patient_form", "Home")}
                />
                <.input
                  type="text"
                  field={relocation_to[:contact_person]}
                  label={dgettext("patient_form", "Contact person")}
                />
                <.input
                  type="text"
                  field={relocation_to[:phone_number]}
                  label={dgettext("patient_form", "Phone number")}
                />
                <.input
                  type="text"
                  field={relocation_to[:fax]}
                  label={dgettext("patient_form", "Fax")}
                />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Treating doctor") %></h1>
            <.inputs_for :let={treating_doctor} field={f[:treating_doctor]} as={:treating_doctor}>
              <div class="flex flex-col gap-2">
                <.input
                  type="text"
                  field={treating_doctor[:name]}
                  label={dgettext("patient_form", "Treating doctor name")}
                />
                <.input
                  type="text"
                  field={treating_doctor[:phone_number]}
                  label={dgettext("patient_form", "Treating doctor phone number")}
                />
                <.input
                  type="text"
                  field={treating_doctor[:fax]}
                  label={dgettext("patient_form", "Treating doctor fax")}
                />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Care relevant pre-existing conditions") %></h1>
            <.inputs_for
              :let={care_relevant_pre_existing_conditions}
              field={f[:care_relevant_pre_existing_conditions]}
              as={:care_relevant_pre_existing_conditions}
            >
              <div class="flex flex-col gap-2">
                <.input
                  type="checkbox"
                  field={care_relevant_pre_existing_conditions[:diabetes]}
                  label={dgettext("patient_form", "Diabetes")}
                />
                <.input
                  type="checkbox"
                  field={care_relevant_pre_existing_conditions[:epilepsy]}
                  label={dgettext("patient_form", "Epilepsy")}
                />
                <.input
                  type="checkbox"
                  field={care_relevant_pre_existing_conditions[:heart_failure]}
                  label={dgettext("patient_form", "Heart failure")}
                />
                <.input
                  type="checkbox"
                  field={care_relevant_pre_existing_conditions[:hypertension]}
                  label={dgettext("patient_form", "Hypertension")}
                />
                <.input
                  type="checkbox"
                  field={care_relevant_pre_existing_conditions[:stroke]}
                  label={dgettext("patient_form", "Stroke")}
                />
                <.input
                  type="checkbox"
                  field={care_relevant_pre_existing_conditions[:cancer]}
                  label={dgettext("patient_form", "Cancer")}
                />
                <.input
                  type="checkbox"
                  field={care_relevant_pre_existing_conditions[:dementia]}
                  label={dgettext("patient_form", "Dementia")}
                />
                <.input
                  type="checkbox"
                  field={care_relevant_pre_existing_conditions[:parkinson]}
                  label={dgettext("patient_form", "Parkinson")}
                />
                <.input
                  type="checkbox"
                  field={care_relevant_pre_existing_conditions[:other]}
                  label={dgettext("patient_form", "Other")}
                />
                <.input
                  type="text"
                  field={care_relevant_pre_existing_conditions[:other_text]}
                  label={dgettext("patient_form", "Other text")}
                />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Allergies") %></h1>
            <.inputs_for :let={allergies} field={f[:allergies]} as={:allergies}>
              <div class="flex flex-col gap-2">
                <.input
                  type="checkbox"
                  field={allergies[:allergy_pass]}
                  label={dgettext("patient_form", "Allergy pass")}
                />
                <.input type="text" field={allergies[:kind]} label={dgettext("patient_form", "Kind")} />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Treatment care instructions") %></h1>
            <.inputs_for
              :let={treatment_care_instructions}
              field={f[:treatment_care_instructions]}
              as={:treatment_care_instructions}
            >
              <div class="flex flex-col gap-2">
                <.input
                  type="text"
                  field={treatment_care_instructions[:text]}
                  label={dgettext("patient_form", "Text")}
                />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Actual medication") %></h1>
            <.inputs_for
              :let={actual_medication}
              field={f[:actual_medication]}
              as={:actual_medication}
            >
              <div class="flex flex-col gap-2">
                <.input
                  type="checkbox"
                  field={actual_medication[:see_attachment_or_discharge_note]}
                  label={dgettext("patient_form", "See attachment or discharge note")}
                />
                <.inputs_for
                  :let={medications}
                  field={actual_medication[:medications]}
                  as={:medications}
                >
                  <div class="flex flex-col gap-2">
                    <.input
                      type="text"
                      field={medications[:name]}
                      label={dgettext("patient_form", "Name")}
                    />
                    <.input
                      type="text"
                      field={medications[:time]}
                      label={dgettext("patient_form", "Time")}
                    />
                  </div>
                </.inputs_for>
                <.inputs_for
                  :let={medications_as_needed}
                  field={actual_medication[:medications_as_needed]}
                  as={:medications_as_needed}
                >
                  <div class="flex flex-col gap-2">
                    <.input
                      type="text"
                      field={medications_as_needed[:name]}
                      label={dgettext("patient_form", "Name")}
                    />
                    <.input
                      type="text"
                      field={medications_as_needed[:time]}
                      label={dgettext("patient_form", "Time")}
                    />
                  </div>
                </.inputs_for>
                <.input
                  type="select"
                  field={actual_medication[:last_medication]}
                  label={dgettext("patient_form", "Last medication")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={
                    Ecto.Enum.mappings(ComposeWeb.PatientForm.ActualMedication, :last_medication)
                  }
                />
                <.input
                  type="datetime-local"
                  field={actual_medication[:time]}
                  label={dgettext("patient_form", "Time")}
                />
                <.input
                  type="datetime-local"
                  field={actual_medication[:last_btm_patch]}
                  label={dgettext("patient_form", "Last BTM patch")}
                />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Existing or prescribed medical aid") %></h1>
            <.inputs_for
              :let={existing_or_prescribed_medical_aid}
              field={f[:existing_or_prescribed_medical_aid]}
              as={:existing_or_prescribed_medical_aid}
            >
              <div class="flex flex-col gap-2">
                <.input
                  type="text"
                  field={existing_or_prescribed_medical_aid[:text]}
                  label={dgettext("patient_form", "Text")}
                />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Skin condition") %></h1>
            <.inputs_for :let={skin_condition} field={f[:skin_condition]} as={:skin_condition}>
              <div class="flex flex-col gap-2">
                <.input
                  type="text"
                  field={skin_condition[:text]}
                  label={dgettext("patient_form", "Skin condition")}
                />

                <.input
                  type="number"
                  field={skin_condition[:decubitus_degree]}
                  label={dgettext("patient_form", "Decubitus degree")}
                />
                <.input
                  type="text"
                  field={skin_condition[:decubitus_size]}
                  label={dgettext("patient_form", "Decubitus size")}
                />
                <.input
                  type="checkbox"
                  field={skin_condition[:ulcer]}
                  label={dgettext("patient_form", "Ulcer")}
                />
                <.input
                  type="text"
                  field={skin_condition[:ulcer_size]}
                  label={dgettext("patient_form", "Ulcer size")}
                />
                <.input
                  type="text"
                  field={skin_condition[:ulcer_location]}
                  label={dgettext("patient_form", "Ulcer location")}
                />
                <.input
                  type="checkbox"
                  field={skin_condition[:fungal_infection]}
                  label={dgettext("patient_form", "Fungal infection")}
                />
                <.input
                  type="text"
                  field={skin_condition[:fungal_infection_location]}
                  label={dgettext("patient_form", "Fungal infection location")}
                />
                <.input
                  type="checkbox"
                  field={skin_condition[:wound_documentation]}
                  label={dgettext("patient_form", "Wound documentation")}
                />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Special care problems") %></h1>
            <.inputs_for :let={special_care} field={f[:special_care]} as={:sepcial_care}>
              <div class="flex flex-col gap-2">
                <.input
                  type="checkbox"
                  field={special_care[:severe_spasticity]}
                  label={dgettext("patient_form", "Severe Spasticity")}
                />
                <.input
                  type="checkbox"
                  field={special_care[:hemiplegia_and_paresis]}
                  label={dgettext("patient_form", "Hemiplegia and Paresis")}
                />
                <.input
                  type="checkbox"
                  field={special_care[:malposition_of_the_extremity]}
                  label={dgettext("patient_form", "Malposition of the extremity")}
                />
                <.input
                  type="checkbox"
                  field={special_care[:limited_resilience_due_to_cardiovascular_diseases]}
                  label={
                    dgettext("patient_form", "Limited resilience due to cardiovascular diseases")
                  }
                />
                <.input
                  type="checkbox"
                  field={special_care[:behavioral_problems_with_mental_illness_and_dementia]}
                  label={
                    dgettext(
                      "patient_form",
                      "Behavioral problems with mental illness and dementia"
                    )
                  }
                />
                <.input
                  type="checkbox"
                  field={special_care[:impaired_sensory_perception]}
                  label={dgettext("patient_form", "Impaired sensory perception")}
                />
                <.input
                  type="checkbox"
                  field={special_care[:therapy_resistant_pain]}
                  label={dgettext("patient_form", "Therapy-resistant pain")}
                />
                <.input
                  type="checkbox"
                  field={special_care[:increased_need_for_care_due_to_body_weight]}
                  label={dgettext("patient_form", "Increased need for care due to body weight")}
                />
                <.input
                  type="checkbox"
                  field={special_care[:weight_bmi]}
                  label={dgettext("patient_form", "Weight/BMI")}
                />
              </div>
            </.inputs_for>
          </section>
          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Mobility") %></h1>
            <.inputs_for :let={mobility} field={f[:mobility]} as={:mobility}>
              <div class="flex flex-col gap-4">
                <.input
                  type="select"
                  field={mobility[:walking]}
                  label={dgettext("patient_form", "Walking")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />

                <.input
                  type="select"
                  field={mobility[:standing]}
                  label={dgettext("patient_form", "Standing")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={mobility[:sitting]}
                  label={dgettext("patient_form", "Sitting")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={mobility[:moving_in_bed]}
                  label={dgettext("patient_form", "Moving in bed")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={mobility[:sitting_down]}
                  label={dgettext("patient_form", "Sitting down")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={mobility[:laying]}
                  label={dgettext("patient_form", "Laying")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input type="text" field={mobility[:aids]} label={dgettext("patient_form", "Aids")} />
                <.input
                  type="text"
                  field={mobility[:mobility_note]}
                  label={dgettext("patient_form", "Remark")}
                  placeholder={dgettext("patient_form", "(e.g. Movement plan)")}
                />
              </div>
            </.inputs_for>
          </section>

          <%!-- rest and sleep section --%>
          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Rest and sleep") %></h1>
            <.inputs_for :let={rest_and_sleep} field={f[:rest_and_sleep]} as={:rest_and_sleep}>
              <div class="flex flex-col gap-4">
                <.input
                  type="checkbox"
                  field={rest_and_sleep[:falling_asleep]}
                  label={dgettext("patient_form", "Falling asleep")}
                />
                <.input
                  type="select"
                  field={rest_and_sleep[:sleep_disruptions]}
                  label={dgettext("patient_form", "Sleep disruptions")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={rest_and_sleep[:sleep_reversal]}
                  label={dgettext("patient_form", "Sleep reversal")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="text"
                  field={rest_and_sleep[:note]}
                  label={dgettext("patient_form", "Note")}
                />
              </div>
            </.inputs_for>
          </section>

          <%!-- breathing section --%>
          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Breathing") %></h1>
            <.inputs_for :let={breathing} field={f[:breathing]} as={:breathing}>
              <div class="flex flex-col gap-4">
                <.input
                  type="checkbox"
                  field={breathing[:sounds]}
                  label={dgettext("patient_form", "Breathing sounds")}
                />
                <.input
                  type="checkbox"
                  field={breathing[:sputum]}
                  label={dgettext("patient_form", "Sputum")}
                />
                <.input
                  type="checkbox"
                  field={breathing[:tracheostomy]}
                  label={dgettext("patient_form", "Tracheostomy")}
                />
                <.input
                  type="datetime-local"
                  field={breathing[:last_cannula_change_at]}
                  label={dgettext("patient_form", "Last cannula change at")}
                />
                <.input type="text" field={breathing[:note]} label={dgettext("patient_form", "Note")} />
              </div>
            </.inputs_for>
          </section>

          <%!-- communication section --%>
          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Communication") %></h1>
            <.inputs_for :let={communication} field={f[:communication]} as={:communication}>
              <div class="flex flex-col gap-4">
                <.input
                  type="checkbox"
                  field={communication[:speaking]}
                  label={dgettext("patient_form", "Speaking")}
                />
                <.input
                  type="checkbox"
                  field={communication[:reading]}
                  label={dgettext("patient_form", "Reading")}
                />
                <.input
                  type="checkbox"
                  field={communication[:understanding]}
                  label={dgettext("patient_form", "Understanding")}
                />
                <.input
                  type="checkbox"
                  field={communication[:writing]}
                  label={dgettext("patient_form", "Writing")}
                />
                <.input
                  type="checkbox"
                  field={communication[:blindness]}
                  label={dgettext("patient_form", "Blindness")}
                />
                <.input
                  type="checkbox"
                  field={communication[:hearing_impairment]}
                  label={dgettext("patient_form", "Hearing impairment")}
                />
                <.input
                  type="checkbox"
                  field={communication[:confusion]}
                  label={dgettext("patient_form", "Confusion")}
                />
                <.input
                  type="checkbox"
                  field={communication[:glasses]}
                  label={dgettext("patient_form", "Glasses")}
                />
                <.input
                  type="select"
                  field={communication[:hearing_aid]}
                  label={dgettext("patient_form", "Hearing aid")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={Ecto.Enum.mappings(ComposeWeb.PatientForm.Communication, :hearing_aid)}
                />
                <.input
                  type="text"
                  field={communication[:note]}
                  label={dgettext("patient_form", "Note")}
                />
              </div>
            </.inputs_for>
          </section>

          <%!-- eating and drinking section --%>
          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Eating and drinking") %></h1>
            <.inputs_for
              :let={eating_and_drinking}
              field={f[:eating_and_drinking]}
              as={:eating_and_drinking}
            >
              <div class="flex flex-col gap-4">
                <.input
                  type="select"
                  field={eating_and_drinking[:help_with_eating]}
                  label={dgettext("patient_form", "Help with eating")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={eating_and_drinking[:help_with_drinking]}
                  label={dgettext("patient_form", "Help with drinking")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:upper_dentures]}
                  label={dgettext("patient_form", "Upper dentures")}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:lower_dentures]}
                  label={dgettext("patient_form", "Lower dentures")}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:chewing_problems]}
                  label={dgettext("patient_form", "Chewing problems")}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:swallowing_problems]}
                  label={dgettext("patient_form", "Swallowing problems")}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:mouth_pain]}
                  label={dgettext("patient_form", "Mouth pain")}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:thirst_restricted]}
                  label={dgettext("patient_form", "Thirst restricted")}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:appetite_restricted]}
                  label={dgettext("patient_form", "Appetite restricted")}
                />
                <.input
                  type="number"
                  field={eating_and_drinking[:recommended_drinking_amount_in_ml_per_day]}
                  label={dgettext("patient_form", "Recommended drinking amount in ml per day")}
                />
                <.input
                  type="text"
                  field={eating_and_drinking[:tube_type]}
                  label={dgettext("patient_form", "Tube type")}
                />
                <.input
                  type="datetime-local"
                  field={eating_and_drinking[:tube_inserted_at]}
                  label={dgettext("patient_form", "Tube inserted at")}
                />
                <.input
                  type="text"
                  field={eating_and_drinking[:tube_nutrition]}
                  label={dgettext("patient_form", "Tube nutrition")}
                />
                <.input
                  type="number"
                  field={eating_and_drinking[:tube_nutrition_amount_in_ml]}
                  label={dgettext("patient_form", "Tube nutrition amount in ml")}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:transnasal_feeding_tube]}
                  label={dgettext("patient_form", "Transnasal feeding tube")}
                />
                <.input
                  type="number"
                  field={eating_and_drinking[:transnasal_feeding_tube_amount_in_ml]}
                  label={dgettext("patient_form", "Transnasal feeding tube amount in ml")}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:administration_per_injection]}
                  label={dgettext("patient_form", "Administration per injection")}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:administration_per_pump]}
                  label={dgettext("patient_form", "Administration per pump")}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:administration_per_gravity]}
                  label={dgettext("patient_form", "Administration per gravity")}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:meals_on_wheels]}
                  label={dgettext("patient_form", "Meals on wheels")}
                />
                <.input
                  type="checkbox"
                  field={eating_and_drinking[:informed]}
                  label={dgettext("patient_form", "Informed")}
                />
                <.input
                  type="text"
                  field={eating_and_drinking[:note]}
                  label={dgettext("patient_form", "Note")}
                />
              </div>
            </.inputs_for>
          </section>

          <%!-- body care section --%>
          <%!-- # Baden/Duschen

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Body care") %></h1>
            <.inputs_for :let={body_care} field={f[:body_care]} as={:body_care}>
              <div class="flex flex-col gap-4">
                <.input
                  type="select"
                  field={body_care[:bathing_and_showering]}
                  label={dgettext("patient_form", "Bathing and showering")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={body_care[:intimate_care]}
                  label={dgettext("patient_form", "Intimate care")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={body_care[:upper_body]}
                  label={dgettext("patient_form", "Upper body")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={body_care[:lower_body]}
                  label={dgettext("patient_form", "Lower body")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={body_care[:hair_care]}
                  label={dgettext("patient_form", "Hair care")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={body_care[:nail_care]}
                  label={dgettext("patient_form", "Nail care")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={body_care[:oral_care]}
                  label={dgettext("patient_form", "Oral care")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={body_care[:shaving]}
                  label={dgettext("patient_form", "Shaving")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={body_care[:upper_body_dressing_and_undressing]}
                  label={dgettext("patient_form", "Upper body dressing and undressing")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={body_care[:lower_body_dressing_and_undressing]}
                  label={dgettext("patient_form", "Lower body dressing and undressing")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input type="text" field={body_care[:note]} label={dgettext("patient_form", "Note")} />
              </div>
            </.inputs_for>
          </section>

          <%!-- psychological situation --%>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Psychological situation") %></h1>
            <.inputs_for
              :let={psychological_situation}
              field={f[:psychological_situation]}
              as={:psychological_situation}
            >
              <div class="flex flex-col gap-4">
                <.input
                  type="select"
                  field={psychological_situation[:consciousness_state]}
                  label={dgettext("patient_form", "Consciousness state")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="checkbox"
                  field={psychological_situation[:daily_structure]}
                  label={dgettext("patient_form", "Daily structure")}
                />
                <.input
                  type="text"
                  field={psychological_situation[:psychological_changes]}
                  label={dgettext("patient_form", "Psychological changes")}
                />
                <.input
                  type="checkbox"
                  field={psychological_situation[:hyper_mobility]}
                  label={dgettext("patient_form", "Hyper mobility")}
                />
                <.input
                  type="checkbox"
                  field={psychological_situation[:restlesness]}
                  label={dgettext("patient_form", "Restlesness")}
                />
                <.input
                  type="checkbox"
                  field={psychological_situation[:fear]}
                  label={dgettext("patient_form", "Fear")}
                />
                <.input
                  type="checkbox"
                  field={psychological_situation[:depressive_mood]}
                  label={dgettext("patient_form", "Depressive mood")}
                />
                <.input
                  type="checkbox"
                  field={psychological_situation[:refuses_help]}
                  label={dgettext("patient_form", "Refuses help")}
                />
                <.input
                  type="select"
                  field={psychological_situation[:oriented]}
                  label={dgettext("patient_form", "Oriented")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={psychological_situation[:disorientation]}
                  label={dgettext("patient_form", "Disorientation")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="text"
                  field={psychological_situation[:note]}
                  label={dgettext("patient_form", "Note")}
                />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Occupy oneself") %></h1>
            <.inputs_for :let={occupy_one_self} field={f[:occupy_one_self]} as={:occupy_one_self}>
              <div class="flex flex-col gap-4">
                <.input
                  type="checkbox"
                  field={occupy_one_self[:reading]}
                  label={dgettext("patient_form", "Reading")}
                />
                <.input
                  type="checkbox"
                  field={occupy_one_self[:radio]}
                  label={dgettext("patient_form", "Radio")}
                />
                <.input
                  type="checkbox"
                  field={occupy_one_self[:tv]}
                  label={dgettext("patient_form", "TV")}
                />
                <.input
                  type="text"
                  field={occupy_one_self[:note]}
                  label={dgettext("patient_form", "Note")}
                />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Gender Identity") %></h1>
            <.inputs_for :let={gender_identity} field={f[:gender_identity]} as={:gender_identity}>
              <div class="flex flex-col gap-4">
                <.input
                  type="text"
                  field={gender_identity[:note]}
                  label={dgettext("patient_form", "Note")}
                />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Bowel movement") %></h1>
            <.inputs_for :let={excretion} field={f[:excretion]} as={:excretion}>
              <div class="flex flex-col gap-4">
                <.input
                  type="select"
                  field={excretion[:adjusting_clothing]}
                  label={dgettext("patient_form", "Adjusting clothing")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={excretion[:hygenic_aftercare]}
                  label={dgettext("patient_form", "Hygenic aftercare")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />

                <.input
                  type="select"
                  field={excretion[:bowel_movement]}
                  label={dgettext("patient_form", "Bowel movement")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={Ecto.Enum.mappings(ComposeWeb.PatientForm.Excretion, :bowel_movement)}
                />
                <.input
                  type="select"
                  field={excretion[:fecal_incontinence]}
                  label={dgettext("patient_form", "Fecal incontinence")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="select"
                  field={excretion[:stoma]}
                  label={dgettext("patient_form", "Stoma")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Legend.values_options()}
                />
                <.input
                  type="datetime-local"
                  field={excretion[:last_bowel_movement_at]}
                  label={dgettext("patient_form", "Last bowel movement at")}
                />
                <.input
                  type="select"
                  field={excretion[:urinary_incontinence]}
                  label={dgettext("patient_form", "Urinary incontinence")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={
                    Ecto.Enum.mappings(ComposeWeb.PatientForm.Excretion, :urinary_incontinence)
                  }
                />
                <.input
                  type="select"
                  field={excretion[:supply_items]}
                  label={dgettext("patient_form", "Supply items")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={Ecto.Enum.mappings(ComposeWeb.PatientForm.Excretion, :supply_items)}
                />
                <.input
                  type="number"
                  field={excretion[:indwelling_catheter_charriere_number]}
                  label={dgettext("patient_form", "Indwelling catheter charriere number")}
                />
                <.input
                  type="datetime-local"
                  field={excretion[:discharge_system_placed_at]}
                  label={dgettext("patient_form", "Discharge system placed at")}
                />
                <.input
                  type="checkbox"
                  field={excretion[:continence_training]}
                  label={dgettext("patient_form", "Continence training")}
                />
                <.input type="text" field={excretion[:note]} label={dgettext("patient_form", "Note")} />
              </div>
            </.inputs_for>
          </section>

          <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <h1><%= dgettext("patient_form", "Attachment") %></h1>
            <.inputs_for :let={attachment} field={f[:attachment]} as={:attachment}>
              <div class="flex flex-col gap-4">
                <.input
                  type="checkbox"
                  field={attachment[:medication_plan]}
                  label={dgettext("patient_form", "Medication plan")}
                />
                <.input
                  type="checkbox"
                  field={attachment[:carer_id_card]}
                  label={dgettext("patient_form", "Carer ID card")}
                />
                <.input
                  type="checkbox"
                  field={attachment[:wound_documentation]}
                  label={dgettext("patient_form", "Wound documentation")}
                />
                <.input
                  type="checkbox"
                  field={attachment[:living_will]}
                  label={dgettext("patient_form", "Living will")}
                />
                <.input
                  type="text"
                  field={attachment[:other]}
                  label={dgettext("patient_form", "Other")}
                />
                <.input
                  type="datetime-local"
                  field={attachment[:telephone_enquiry_at]}
                  label={dgettext("patient_form", "Telephone enquiry at")}
                />
                <.input
                  type="text"
                  field={attachment[:note]}
                  label={dgettext("patient_form", "Note")}
                />
              </div>
            </.inputs_for>
          </section>

          <%!-- <section class="flex flex-col gap-8 border border-b-1 rounded-md shadow-sm p-8">
            <.inputs_for :let={signature} field={f[:signature]} as={:signature}>
              <div class="flex flex-col gap-4">
                <.input type="text" field={signature[:date]} value={Date.utc_today()} label="Datum" />
                <.input type="text" field={signature[:signature]} label="Signature" />
              </div>
            </.inputs_for>
          </section> --%>
          <%!-- <.button>Speichern</.button> --%>
        </.form>
        <div class="col-span-1" />
      </div>
    </div>
    """
  end

  @impl LiveView
  def handle_event(
        "change_patient_report",
        %{
          "backend" => backend,
          "model" => model,
          "prompt_mode" => prompt_mode
        } = _params,
        socket
      ) do
    backend = String.to_existing_atom(backend)
    prompt_mode = String.to_existing_atom(prompt_mode)

    socket =
      socket
      |> assign(backend: backend)
      |> assign(models: backend.models())
      |> assign(model: (model in backend.models() && model) || backend.default_model())
      |> assign(
        prompt_mode: (prompt_mode in Compose.LLM.prompt_modes() && prompt_mode) || :per_form
      )

    {:noreply, socket}
  end

  def handle_event("submit_patient_report", params, socket) do
    backend = socket.assigns.backend
    model = socket.assigns.model
    prompt_mode = socket.assigns.prompt_mode
    locale = socket.assigns.locale
    patient_report = params["patient_report"]

    socket =
      assign_async(socket, [:response, :changeset, :error], fn ->
        generate(%{
          backend: backend,
          model: model,
          patient_report: patient_report,
          locale: locale,
          prompt_mode: prompt_mode,
          parse_output: true
        })
      end)

    {:noreply, socket}
  end

  def handle_event("submit", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("change_locale", params, socket) do
    locale = params["locale"]
    {:noreply, redirect(socket, to: ~p"/#{locale}/form")}
  end

  defp generate(%{} = params) do
    case Compose.LLM.generate(params) do
      {:ok, response} ->
        changeset = ComposeWeb.PatientForm.changeset(%ComposeWeb.PatientForm{}, response)
        Logger.debug("#{inspect(changeset, pretty: true, printable_limit: :infinity)}")
        {:ok, %{response: response, changeset: changeset, error: nil}}

      {:error, error} ->
        Logger.error("#{inspect(error, pretty: true, printable_limit: :infinity)}")
        {:error, %{error: error, response: nil, changeset: nil}}
    end
  end
end
