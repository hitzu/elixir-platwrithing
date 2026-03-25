defmodule PhoenixPlaywrithingWeb.ContactPreferenceLive do
  use PhoenixPlaywrithingWeb, :live_view

  @contact_options [{"Email", "email"}, {"WhatsApp", "whatsapp"}]
  @time_options [
    {"Morning (8am – 12pm)", "morning"},
    {"Afternoon (12pm – 5pm)", "afternoon"},
    {"Evening (5pm – 8pm)", "evening"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Contact Preference",
       form: to_form(empty_form()),
       submitted: false,
       errors: %{},
       contact_options: @contact_options,
       time_options: @time_options
     )}
  end

  @impl true
  def handle_event("validate", params, socket) do
    errors = validate_fields(params)

    {:noreply,
     assign(socket,
       form: to_form(params),
       errors: errors
     )}
  end

  @impl true
  def handle_event("submit", params, socket) do
    errors = validate_fields(params)

    if map_size(errors) == 0 do
      {:noreply, assign(socket, submitted: true)}
    else
      {:noreply, assign(socket, form: to_form(params), errors: errors)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div data-testid="page-title" class="mb-8">
        <h1 class="text-3xl font-bold">Contact Preference</h1>
        <p class="text-base-content/60 mt-1">
          Tell us how and when you'd like to be contacted.
        </p>
      </div>

      <div :if={@submitted} data-testid="success-message" class="alert alert-success mb-6">
        <span class="font-semibold">Your preferences have been saved</span>
      </div>

      <div :if={!@submitted} class="card bg-base-200 border border-base-300">
        <div class="card-body">
          <form phx-change="validate" phx-submit="submit" class="space-y-5">
            <div>
              <label class="label" for="full_name">
                <span class="label-text font-medium">Full Name</span>
              </label>
              <input
                id="full_name"
                type="text"
                name="full_name"
                value={@form[:full_name].value}
                placeholder="Jane Doe"
                autocomplete="off"
                data-testid="input-full-name"
                class={["input input-bordered w-full", @errors[:full_name] && "input-error"]}
              />
              <p :if={@errors[:full_name]} data-testid="error-full-name" class="text-error text-sm mt-1">
                {@errors[:full_name]}
              </p>
            </div>

            <div>
              <label class="label" for="email">
                <span class="label-text font-medium">Email</span>
              </label>
              <input
                id="email"
                type="email"
                name="email"
                value={@form[:email].value}
                placeholder="jane@example.com"
                autocomplete="off"
                data-testid="input-email"
                class={["input input-bordered w-full", @errors[:email] && "input-error"]}
              />
              <p :if={@errors[:email]} data-testid="error-email" class="text-error text-sm mt-1">
                {@errors[:email]}
              </p>
            </div>

            <div>
              <label class="label" for="preferred_contact">
                <span class="label-text font-medium">Preferred Contact Channel</span>
              </label>
              <select
                id="preferred_contact"
                name="preferred_contact"
                data-testid="input-preferred-contact"
                class={["select select-bordered w-full", @errors[:preferred_contact] && "select-error"]}
              >
                <option value="">-- Select channel --</option>
                <option
                  :for={{label, value} <- @contact_options}
                  value={value}
                  selected={@form[:preferred_contact].value == value}
                >
                  {label}
                </option>
              </select>
              <p :if={@errors[:preferred_contact]} data-testid="error-preferred-contact" class="text-error text-sm mt-1">
                {@errors[:preferred_contact]}
              </p>
            </div>

            <div>
              <label class="label" for="preferred_time">
                <span class="label-text font-medium">Preferred Time</span>
              </label>
              <select
                id="preferred_time"
                name="preferred_time"
                data-testid="input-preferred-time"
                class={["select select-bordered w-full", @errors[:preferred_time] && "select-error"]}
              >
                <option value="">-- Select time --</option>
                <option
                  :for={{label, value} <- @time_options}
                  value={value}
                  selected={@form[:preferred_time].value == value}
                >
                  {label}
                </option>
              </select>
              <p :if={@errors[:preferred_time]} data-testid="error-preferred-time" class="text-error text-sm mt-1">
                {@errors[:preferred_time]}
              </p>
            </div>

            <button type="submit" data-testid="submit-button" class="btn btn-primary w-full">
              Save Preferences
            </button>
          </form>
        </div>
      </div>

      <div :if={@submitted} class="text-center mt-4">
        <a href="/contact-preference" class="btn btn-ghost btn-sm">Start over</a>
      </div>
    </Layouts.app>
    """
  end

  defp empty_form do
    %{"full_name" => "", "email" => "", "preferred_contact" => "", "preferred_time" => ""}
  end

  defp validate_fields(params) do
    %{}
    |> check(:full_name, String.trim(params["full_name"] || "") == "", "Full name is required")
    |> check(:email, !valid_email?(params["email"] || ""), "Valid email is required")
    |> check(:preferred_contact, blank?(params["preferred_contact"]), "Please select a contact channel")
    |> check(:preferred_time, blank?(params["preferred_time"]), "Please select a preferred time")
  end

  defp check(errors, _key, false, _msg), do: errors
  defp check(errors, key, true, msg), do: Map.put(errors, key, msg)

  defp blank?(val), do: is_nil(val) or String.trim(val) == ""

  defp valid_email?(email) do
    String.match?(String.trim(email), ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
  end
end
