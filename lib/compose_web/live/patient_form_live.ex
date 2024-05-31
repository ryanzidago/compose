defmodule ComposeWeb.PatientFormLive do
  use ComposeWeb, :live_view

  alias ComposeWeb.PatientForm
  alias Phoenix.LiveView

  @impl LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_async(:changeset, fn ->
        {:ok, %{changeset: PatientForm.changeset(%PatientForm{})}}
      end)
      |> assign_async(:response, fn -> {:ok, %{response: nil}} end)
      |> assign(patient_report: nil)
      |> assign(models: Compose.LLM.tags())
      |> assign(model: "llama3:latest")

    {:ok, socket}
  end

  @impl LiveView
  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-1">
      <div class="flex flex-row gap-20 justify-center">
        <.form for={%{}} phx-submit="submit_patient_report" class="flex flex-col gap-8">
          <div class="flex flex-col gap-2">
            <.input
              type="textarea"
              value={@patient_report}
              name="patient_report"
              label="Schreib hier den Text, der die Patienteninformationen enthält."
              class="h-60"
            />
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

        <.form :let={f} for={@changeset.result} phx-submit="submit" class="flex flex-col gap-8">
          <section class="flex flex-col gap-8">
            <h1>Patienteninformation</h1>
            <ul class="flex flex-col gap-2">
              <li>
                <.input type="text" field={f[:first_name]} label="Vorname" />
              </li>
              <li>
                <.input type="text" field={f[:last_name]} label="Nachname" />
              </li>
            </ul>
          </section>
          <section class="flex flex-col gap-8">
            <h1>Besondere Pflegeprobleme</h1>
            <ul class="flex flex-col gap-2">
              <li>
                <.input type="checkbox" field={f[:severe_spasticity]} label="Hochgradige Spastik" />
              </li>
              <li>
                <.input
                  type="checkbox"
                  field={f[:hemiplegia_and_paresis]}
                  label="Hemiplegien und Paresen"
                />
              </li>
              <li>
                <.input
                  type="checkbox"
                  field={f[:malposition_of_the_extremity]}
                  label="Fehlhaltung der Extremität"
                />
              </li>
              <li>
                <.input
                  type="checkbox"
                  field={f[:limited_resilience_due_to_cardiovascular_diseases]}
                  label="Eingeschränkte Belastbarkeit aufgrund von Herz-Kreislauf-Erkrankungen"
                />
              </li>
              <li>
                <.input
                  type="checkbox"
                  field={f[:behavioral_problems_with_mental_illness_and_dementia]}
                  label="Verhaltensauffälligkeiten bei psychischen Erkrankungen und Demenz"
                />
              </li>
              <li>
                <.input
                  type="checkbox"
                  field={f[:impaired_sensory_perception]}
                  label="Eingeschränkte Sinneswahrnehmung"
                />
              </li>
              <li>
                <.input
                  type="checkbox"
                  field={f[:therapy_resistant_pain]}
                  label="Therapieresistenter Schmerz"
                />
              </li>
              <li>
                <.input
                  type="checkbox"
                  field={f[:increased_need_for_care_due_to_body_weight]}
                  label="Erhöhter Pflegebedarf durch Körpergewicht"
                />
              </li>
              <li>
                <.input type="checkbox" field={f[:weight_bmi]} label="Gewicht/BMI" />
              </li>
            </ul>
          </section>
          <section class="flex flex-col gap-8">
            <h1>Mobilität</h1>
            <ul class="flex flex-col gap-4">
              <li>
                <.input
                  type="select"
                  field={f[:walking]}
                  label="Gehen"
                  prompt="Wähle eine Option"
                  options={ComposeWeb.PatientForm.mobility_values_options()}
                />
              </li>
              <li>
                <.input
                  type="text"
                  field={f[:mobility_note]}
                  label="Bemerkung"
                  placeholder="(z. B. Bewegungsplan)"
                />
              </li>
            </ul>
          </section>
          <section class="flex flex-col gap-8">
            <ul class="flex flex-col gap-4">
              <li>
                <.input type="text" field={f[:date]} value={Date.utc_today()} label="Datum" />
              </li>
              <li>
                <.input type="text" field={f[:signature]} label="Signature" />
              </li>
            </ul>
          </section>
          <%!-- <.button>Speichern</.button> --%>
        </.form>
      </div>
    </div>
    """
  end

  @impl LiveView
  def handle_event("submit_patient_report", params, socket) do
    prompt = """
    Please, fill out the following JSON form:
    #{Jason.encode!(%ComposeWeb.PatientForm{})}

    Using the following information about the patient:

    ```text
    #{params["patient_report"]}
    ```
    """

    model = params["model"]

    socket =
      assign_async(socket, [:response, :changeset], fn ->
        response = Compose.LLM.generate!(%{prompt: prompt, model: model})
        changeset = ComposeWeb.PatientForm.changeset(%ComposeWeb.PatientForm{}, response)
        {:ok, %{response: response, changeset: changeset}}
      end)

    {:noreply, socket}
  end

  def handle_event("submit", _params, socket) do
    {:noreply, socket}
  end
end
