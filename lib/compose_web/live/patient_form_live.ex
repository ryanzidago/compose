defmodule ComposeWeb.PatientFormLive do
  use ComposeWeb, :live_view

  alias ComposeWeb.PatientForm
  alias Phoenix.LiveView

  @impl LiveView
  def mount(%{"locale" => locale}, _session, socket) do
    Gettext.put_locale(locale)

    socket =
      socket
      |> assign_async(:changeset, fn ->
        {:ok, %{changeset: PatientForm.changeset(%{})}}
      end)
      |> assign_async(:response, fn -> {:ok, %{response: nil}} end)
      |> assign(patient_report: nil)
      |> assign_backend_config()
      |> assign(locales: ~w(en de_DE))
      |> assign(locale: locale)

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
              class="h-60"
            />
            <.input type="select" name="backend" label="Backend" value={@backend} options={@backends} />
            <.input type="select" name="model" label="Model" value={@model} options={@models} />
          </div>
          <.button :if={!@response.loading}>Senden</.button>
          <.button :if={@response.loading} class="opacity-80 cursor-progress">
            Lädt...
          </.button>
          <div :if={@response.result} class="text-xs w-96 overflow-x-auto">
            <h2>Antwort:</h2>
            <pre class="w-90"><%= Jason.encode!(@response.result || "", pretty: true) %></pre>
          </div>
        </.form>

        <.form
          :let={f}
          for={@changeset.result}
          class="col-span-2 flex flex-col gap-8"
          as={:patient_form}
        >
          <section class="flex flex-col gap-8">
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
              </div>
            </.inputs_for>
          </section>
          <section class="flex flex-col gap-8">
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
          <section class="flex flex-col gap-8">
            <h1><%= dgettext("patient_form", "Mobility") %></h1>
            <.inputs_for :let={mobility} field={f[:mobility]} as={:mobility}>
              <div class="flex flex-col gap-4">
                <.input
                  type="select"
                  field={mobility[:walking]}
                  label={dgettext("patient_form", "Walking")}
                  prompt={dgettext("patient_form", "Select an option")}
                  options={ComposeWeb.PatientForm.Mobility.mobility_values_options()}
                />
                <.input
                  type="text"
                  field={mobility[:mobility_note]}
                  label={dgettext("patient_form", "Remark")}
                  placeholder={dgettext("patient_form", "(e.g. Movement plan)")}
                />
              </div>
            </.inputs_for>
          </section>
          <%!-- <section class="flex flex-col gap-8">
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
  def handle_event("change_patient_report", %{"backend" => backend, "model" => model}, socket) do
    backend = String.to_existing_atom(backend)

    socket =
      socket
      |> assign(backend: backend)
      |> assign(models: backend.models())
      |> assign(model: (model in backend.models() && model) || backend.default_model())

    {:noreply, socket}
  end

  def handle_event("submit_patient_report", params, socket) do
    backend = socket.assigns.backend
    model = socket.assigns.model
    patient_report = params["patient_report"]

    socket =
      assign_async(socket, [:response, :changeset], fn ->
        # response =
        #   PatientForm.schema()
        #   |> Map.keys()
        #   |> Map.new(fn section ->
        #     encoded_schema =
        #       PatientForm.schema()
        #       |> Map.get(section)
        #       |> Jason.encode!()

        #     prompt = Jason.encode!(%{patient_information: patient_report, form: encoded_schema})

        #     {Atom.to_string(section), Compose.LLM.generate!(%{prompt: prompt, model: model})}
        #   end)

        prompt =
          Jason.encode!(%{
            locale: Gettext.get_locale(),
            patient_information: patient_report,
            form: Jason.encode!(PatientForm.schema())
          })

        response = Compose.LLM.generate!(%{prompt: prompt, model: model}, backend: backend)
        changeset = ComposeWeb.PatientForm.changeset(%ComposeWeb.PatientForm{}, response)

        IO.inspect(changeset)

        {:ok, %{response: response, changeset: changeset}}
      end)

    {:noreply, socket}
  end

  def handle_event("submit", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("change_locale", params, socket) do
    locale = params["locale"]
    {:noreply, redirect(socket, to: "/#{locale}/form")}
  end
end
