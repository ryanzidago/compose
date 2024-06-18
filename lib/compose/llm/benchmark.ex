defmodule Compose.LLM.Benchmark do
  alias ComposeWeb.PatientForm

  alias Compose.LLM.Backend.Ollama
  alias Compose.LLM.Backend.OpenAI
  alias Compose.LLM.Backend.Mistral
  alias Compose.LLM.Backend.Perplexity

  def execute(config \\ []) do
    config = Keyword.merge(config(), config)

    iterations = Keyword.fetch!(config, :iterations)
    prompt_modes = Keyword.fetch!(config, :prompt_modes)
    models = Keyword.fetch!(config, :models)
    locale = Keyword.fetch!(config, :locale)
    patient_report = Keyword.fetch!(config, :patient_report)
    parse_output = Keyword.fetch!(config, :parse_output)
    expected = Keyword.fetch!(config, :expected)

    rows =
      Enum.flat_map(models, fn {backend, model} ->
        Enum.flat_map(prompt_modes, fn prompt_mode ->
          Enum.map(1..iterations, fn _iteration ->
            {time, result} =
              :timer.tc(fn ->
                Compose.LLM.generate(%{
                  locale: locale,
                  patient_report: patient_report,
                  backend: backend,
                  model: model,
                  prompt_mode: prompt_mode,
                  parse_output: parse_output
                })
              end)

            result =
              case result do
                {:ok, response} -> %{response: response, error: nil}
                {:error, error} -> %{response: nil, error: error}
              end

            changeset =
              if not is_nil(result[:response]) do
                PatientForm.changeset(%PatientForm{}, result[:response])
              end

            diff = diff(expected, result[:response])

            matches? =
              if not is_nil(diff) do
                Enum.all?(diff, fn {_section_key, section_values} ->
                  Enum.empty?(section_values)
                end)
              else
                false
              end

            [
              prompt_mode: prompt_mode,
              backend: backend(backend),
              model: model,
              response: response(result),
              valid?: valid?(result, changeset),
              valid_count: if(valid?(result, changeset), do: 1, else: 0),
              json_error?: json_error?(result),
              json_error_count: if(json_error?(result), do: 1, else: 0),
              json_error: json_error(result),
              changeset_error?: changeset_error?(changeset),
              changeset_error_count: if(changeset_error?(changeset), do: 1, else: 0),
              changeset: changeset(changeset),
              matches?: matches?,
              matches_count: if(matches?, do: 1, else: 0),
              diff: inspect(diff, pretty: true, printable_limit: :infinity),
              duration_in_seconds: time / 1_000_000
            ]
          end)
        end)
      end)

    headers = rows |> List.first() |> Enum.map(fn {key, _} -> Atom.to_string(key) end)
    rows = Enum.map(rows, &Keyword.values/1)

    Compose.CSV.to_file([headers | rows], "benchmark.csv")
  end

  def test_config do
    Keyword.merge(config(),
      iterations: 1,
      prompt_modes: [:per_form],
      models: [{Ollama, "llama3:latest"}]
    )
  end

  def config do
    [
      iterations: 10,
      locale: "en",
      prompt_modes: [:per_form],
      parse_output: true,
      models: [
        # {Ollama, "llama3:latest"},
        # {Ollama, "mistral:latest"},
        # {Ollama, "phi3:latest"},
        # {Ollama, "gemma:latest"},
        {OpenAI, "gpt-4o"},
        # {Mistral, "mistral-small-latest"},
        {Mistral, "mistral-large-latest"},
        {Mistral, "open-mixtral-8x22b"}
        # {Perplexity, "llama-3-70b-instruct"}
      ],
      patient_report: """
      **Patient Report for John Doe**

      John Doe, born on January 15, 1950, resides at 1234 Elm Street, Springfield, IL. He speaks English as his mother tongue and follows Christianity. John possesses both a health insurance card and an ID card, though he does not have additional insurance. His approved care level is 2, which was requested on June 1, 2024. He is not exempt from co-payment.

      Medications for John were last administered this morning, June 15, 2024, at 8:00 AM, with his last BTM patch applied on June 10, 2024. He takes Lisinopril in the morning and Metformin in the evening. As needed, he takes Ibuprofen. Relevant notes and attachments about his medication plan are available.

      John has a known allergy to penicillin and possesses an allergy pass. Additional documentation includes wound documentation, a note about a wound on his left leg under treatment, and confirmations of a carer ID card, living will, and medication plan. A telephone enquiry was made on June 14, 2024, at 9:00 AM.

      Jane Doe is John's authorised representative. She can be contacted via email at jane.doe@example.com or fax at 123-456-7890. She holds a general power of attorney for John. Social services are involved, specifically Springfield Social Services, which can be reached at 123-555-7890. John's valuable items include jewelry and an apartment key.

      For body care, John needs assistance with personal hygiene. He requires support with bathing, showering, hair care, intimate care, lower body dressing, upper body dressing, and shaving. John needs supervision for nail care and instructions for oral care.

      John has respiratory issues, evidenced by the presence of breathing sounds. He uses an oxygen device, and his last cannula change was on June 12, 2024.

      John's pre-existing conditions include diabetes and hypertension, with his last hospital stay being at Springfield General Hospital. Communication-wise, he is hard of hearing and wears a hearing aid in his right ear. He uses glasses and can read, speak, understand, and write.

      John is informed about his eating and drinking requirements. He needs support with drinking and eating but has no dietary restrictions or problems with chewing or swallowing. He wears upper dentures and is recommended to drink 2000 ml of fluids per day.

      Regarding excretion, John needs support in adjusting clothing and hygienic aftercare. His bowel movements are normal, but he sometimes experiences fecal and urinary incontinence. His last bowel movement was on June 14, 2024, at 7:00 AM. His stoma care is managed by stoma therapists, and he uses an indwelling catheter.

      John uses a wheelchair and a walker for mobility. He requires support for laying, moving in bed, sitting, sitting down, standing, and walking. He enjoys reading and watching TV, listening to the radio, and generally maintaining a daily structure. He is partially oriented but experiences occasional depressive moods and temporal disorientation.

      John recently relocated from Springfield Rehabilitation Center to his home at 1234 Elm Street, Springfield, IL. His primary contact is Jane Doe, reachable at 123-555-7892 or via fax at 123-555-7893. Jane is also his representative and daughter, and she can be contacted on her private mobile number, 123-555-7894.

      John's rest and sleep are occasionally disrupted, and he requires support to manage these disruptions. His skin condition includes a wound on his left leg, documented as a decubitus ulcer of degree 2, measuring 2 cm by 3 cm. He has no fungal infections or other ulcers.

      For special care, John has limited resilience due to cardiovascular diseases, and his BMI is 24.5. Dr. William Hart is John's treating doctor, and he can be contacted at 123-555-7895 or fax at 123-555-7896.

      The treatment care instructions for John include continuing wound care, monitoring blood pressure and glucose levels daily, administering medications as prescribed, and providing support with personal hygiene and mobility. Ensuring that John remains hydrated and eats regularly is also crucial.

      This concludes the patient report for John Doe, as of June 15, 2024. Further updates will be provided as necessary.
      """,
      expected: %{
        "actual_medication" => %{
          "last_btm_patch_at" => "2024-06-10T00:00:00Z",
          "last_medication" => "morning",
          "medications" => [
            %{"name" => "Lisinopril", "time" => "morning"},
            %{"name" => "Metformin", "time" => "evening"}
          ],
          "medications_as_needed" => [%{"name" => "Ibuprofen", "time" => "as needed"}],
          "see_attachment_or_discharge_note" => true,
          "time" => "2024-06-15T08:00:00Z"
        },
        "allergies" => %{"has_allergy_pass" => true, "kind" => "penicillin"},
        "attachment" => %{
          "has_carer_id_card" => true,
          "has_living_will" => true,
          "has_medication_plan" => true,
          "has_wound_documentation" => true,
          "note" => "Wound on left leg under treatment.",
          "other" => "Wound documentation and treatment note.",
          "telephone_enquiry_at" => "2024-06-14T09:00:00Z"
        },
        "authorised_representative" => %{
          "email" => "jane.doe@example.com",
          "fax_number" => "123-456-7890",
          "first_name" => "Jane",
          "has_general_power_of_attorney" => true,
          "is_authorised_representative" => true,
          "is_legal_guardian" => false,
          "last_name" => "Doe",
          "living_will_exists" => true,
          "other_value_items" => "jewelry, apartment key",
          "social_service_involved" => true,
          "social_service_name" => "Springfield Social Services",
          "social_service_phone_number" => "123-555-7890",
          "valuable_items" => ["jewelry", "apartment_key"]
        },
        "body_care" => %{
          "bathing_and_showering" => "support",
          "hair_care" => "support",
          "intimate_care" => "support",
          "lower_body" => "support",
          "lower_body_dressing_and_undressing" => "support",
          "nail_care" => "supervision",
          "note" => "John needs assistance with personal hygiene.",
          "oral_care" => "instruction",
          "shaving" => "support",
          "upper_body" => "support",
          "upper_body_dressing_and_undressing" => "support"
        },
        "breathing" => %{
          "has_oxigen_device" => true,
          "has_sputum" => false,
          "has_tracheostomy" => false,
          "last_cannula_change_at" => "2024-06-12T00:00:00Z",
          "make_sounds" => true,
          "note" => "John has respiratory issues and uses an oxygen device."
        },
        "care_relevant_pre_existing_conditions" => %{
          "infections" => "",
          "last_hospital_stay_location" => "Springfield General Hospital",
          "text" => "Diabetes and hypertension"
        },
        "communication" => %{
          "can_read" => true,
          "can_speak" => true,
          "can_understand" => true,
          "can_write" => true,
          "has_blindness" => false,
          "has_glasses" => true,
          "has_hearing_impairment" => true,
          "hearing_aid" => "right",
          "is_confused" => false,
          "note" => ""
        },
        "eating_and_drinking" => %{
          "has_administration_per_gravity" => false,
          "has_administration_per_injection" => false,
          "has_administration_per_pump" => false,
          "has_appetite_restricted" => false,
          "has_chewing_problems" => false,
          "has_lower_dentures" => false,
          "has_meals_on_wheels" => false,
          "has_mouth_pain" => false,
          "has_swallowing_problems" => false,
          "has_thirst_restricted" => false,
          "has_upper_dentures" => true,
          "help_with_drinking" => "support",
          "help_with_eating" => "support",
          "is_informed" => true,
          "note" => "John needs support with drinking and eating.",
          "recommended_drinking_amount_in_ml_per_day" => 2000,
          "transnasal_feeding_tube" => false,
          "transnasal_feeding_tube_amount_in_ml" => nil,
          "tube_inserted_at" => nil,
          "tube_nutrition" => "",
          "tube_nutrition_amount_in_ml" => nil,
          "tube_type" => ""
        },
        "excretion" => %{
          "adjusting_clothing" => "support",
          "bowel_movement" => "normal",
          "discharge_system_placed_at" => nil,
          "fecal_incontinence" => "sometimes",
          "has_continence_training" => false,
          "hygenic_aftercare" => "support",
          "indwelling_catheter_charriere_number" => nil,
          "last_bowel_movement_at" => "2024-06-14T07:00:00Z",
          "note" => "",
          "stoma" => "care_by_stoma_therapists",
          "supply_items" => ["indwelling_catheter"],
          "urinary_incontinence" => "sometimes"
        },
        "existing_or_prescribed_medical_aid" => %{"text" => ""},
        "gender_identity" => %{"note" => ""},
        "mobility" => %{
          "aids" => "wheelchair and walker",
          "laying" => "support",
          "moving_in_bed" => "support",
          "note" => "",
          "sitting" => "support",
          "sitting_down" => "support",
          "standing" => "support",
          "walking" => "support"
        },
        "occupy_one_self" => %{
          "can_read" => true,
          "note" => "",
          "uses_radio" => true,
          "uses_tv" => true
        },
        "personal_information" => %{
          "address" => "1234 Elm Street, Springfield, IL",
          "birth_date" => "1950-01-15",
          "care_level_approved" => "2",
          "care_level_requested_at" => "2024-06-01T00:00:00Z",
          "first_name" => "John",
          "has_additional_insurance" => false,
          "has_health_insurance_card" => true,
          "id_card" => true,
          "is_exempt_from_co_payment" => false,
          "last_name" => "Doe",
          "mother_tongue" => "English",
          "paragraph_37_section_1_approved_until" => nil,
          "paragraph_37_section_2_approved_until" => nil,
          "paragraph_37b_approved_until" => nil,
          "paragraph_42_approved_until" => nil,
          "religion" => "Christianity"
        },
        "psychological_situation" => %{
          "consciousness_state" => "awake",
          "disorientation" => "temporal",
          "has_daily_structure" => true,
          "has_depressive_mood" => true,
          "has_fear" => false,
          "is_hyper_mobile" => false,
          "is_restless" => false,
          "note" => "John experiences occasional depressive moods and temporal disorientation.",
          "oriented" => "partially",
          "psychological_changes" => "",
          "refuses_help" => false
        },
        "relocation_from" => %{
          "address" => "Springfield Rehabilitation Center",
          "contact_person" => "Jane Doe",
          "fax" => "123-555-7893",
          "phone_number" => "123-555-7892"
        },
        "relocation_to" => %{
          "address" => "1234 Elm Street, Springfield, IL",
          "contact_person" => "Jane Doe",
          "fax" => "123-555-7893",
          "is_home" => true,
          "phone_number" => "123-555-7892"
        },
        "representative" => %{
          "degree_of_relationship" => "daughter",
          "first_name" => "Jane",
          "is_informed" => true,
          "is_representative" => true,
          "last_name" => "Doe",
          "mobile_number" => "123-555-7894",
          "mobile_number_type" => "private",
          "phone_number" => "123-555-7892",
          "phone_number_type" => "private"
        },
        "rest_and_sleep" => %{
          "can_fall_asleep" => true,
          "note" => "John's rest and sleep are occasionally disrupted.",
          "sleep_disruptions" => "support",
          "sleep_reversal" => "support"
        },
        "skin_condition" => %{
          "decubitus_degree" => 2,
          "decubitus_size" => "2 cm by 3 cm",
          "fungal_infection_location" => "",
          "has_fungal_infection" => false,
          "has_ulcer" => false,
          "has_wound_documentation" => true,
          "text" => "John has a wound on his left leg.",
          "ulcer_location" => "",
          "ulcer_size" => ""
        },
        "special_care" => %{
          "has_behavioral_problems_with_mental_illness_and_dementia" => false,
          "has_hemiplegia_and_paresis" => false,
          "has_impaired_sensory_perception" => false,
          "has_increased_need_for_care_due_to_body_weight" => false,
          "has_limited_resilience_due_to_cardiovascular_diseases" => true,
          "has_malposition_of_the_extremity" => false,
          "has_severe_spasticity" => false,
          "has_therapy_resistant_pain" => false,
          "has_weight_bmi_issues" => false
        },
        "treating_doctor" => %{
          "fax" => "123-555-7896",
          "name" => "Dr. William Hart",
          "phone_number" => "123-555-7895"
        },
        "treatment_care_instructions" => %{
          "text" =>
            "Continue wound care, monitor blood pressure and glucose levels daily, administer medications as prescribed, provide support with personal hygiene and mobility, ensure hydration and regular meals."
        }
      }
    ]
  end

  defp json_error?(result), do: not is_nil(result[:error])
  defp changeset_error?(nil), do: false
  defp changeset_error?(%Ecto.Changeset{} = changeset), do: not changeset.valid?

  defp json_error(result) do
    case result[:error] do
      %Jason.DecodeError{} = error -> inspect(error, pretty: true, printable_limit: :infinity)
      _ -> ""
    end
  end

  # returns a diff between the expected and actual response
  def diff(_, nil), do: nil

  def diff(%{} = expected, %{} = response) do
    expected_sections = Map.keys(expected)

    Enum.reduce(expected_sections, %{}, fn section, acc ->
      expected_section = Map.get(expected, section)
      actual_section = Map.get(response, section, %{})
      diff = do_diff(expected_section, actual_section)
      Map.put_new(acc, section, diff)
    end)
  end

  defp do_diff(%{} = expected, %{} = actual) do
    Enum.reduce(expected, %{}, fn
      {"mobility_note", expected_value}, acc ->
        actual_value = Map.get(actual, "mobility_note", "")

        if String.contains?(actual_value, "walk") do
          acc
        else
          Map.put(acc, "mobility_note", expected: expected_value, actual: actual_value)
        end

      {"walking", expected_value}, acc ->
        actual_value = Map.get(actual, "walking", "")

        if actual_value in ~w(support partial_takeover complete_takeover) do
          acc
        else
          Map.put(acc, "walking", expected: expected_value, actual: actual_value)
        end

      {key, false}, acc ->
        actual_value = Map.get(actual, key, false)

        if actual_value in [nil, false] do
          acc
        else
          Map.put(acc, key, expected: false, actual: actual_value)
        end

      {key, expected_value}, acc ->
        actual_value = Map.get(actual, key)

        {actual_value, expected_value} =
          if expected_value in [nil, ""] and actual_value in [nil, ""] do
            {nil, nil}
          else
            {actual_value, expected_value}
          end

        if expected_value != actual_value do
          Map.put(acc, key, expected: expected_value, actual: actual_value)
        else
          acc
        end
    end)
  end

  defp response(nil), do: ""

  defp response(%{} = result) do
    inspect(result[:response], pretty: true, printable_limit: :infinity)
  end

  defp changeset(nil), do: ""

  defp changeset(%Ecto.Changeset{} = changeset) do
    inspect(changeset, pretty: true, printable_limit: :infinity)
  end

  defp valid?(%{} = result, changeset) do
    not json_error?(result) and not changeset_error?(changeset)
  end

  defp backend(module) do
    module
    |> Module.split()
    |> List.last()
    |> String.downcase()
  end
end
