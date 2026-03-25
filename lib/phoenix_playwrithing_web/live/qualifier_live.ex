defmodule PhoenixPlaywrithingWeb.QualifierLive do
  use PhoenixPlaywrithingWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Qualifier",
       form: to_form(%{"full_name" => "", "email" => "", "debt_amount" => ""}),
       eligibility: nil,
       submitted: false,
       errors: %{}
     )}
  end

  @impl true
  def handle_event("validate", %{"full_name" => name, "email" => email, "debt_amount" => amount}, socket) do
    errors = validate_fields(name, email, amount)
    eligibility = maybe_check_eligibility(amount)

    {:noreply,
     assign(socket,
       form: to_form(%{"full_name" => name, "email" => email, "debt_amount" => amount}),
       errors: errors,
       eligibility: eligibility
     )}
  end

  @impl true
  def handle_event("submit", %{"full_name" => name, "email" => email, "debt_amount" => amount}, socket) do
    errors = validate_fields(name, email, amount)

    if map_size(errors) == 0 do
      {:noreply, assign(socket, submitted: true, eligibility: check_eligibility(amount))}
    else
      {:noreply,
       assign(socket,
         form: to_form(%{"full_name" => name, "email" => email, "debt_amount" => amount}),
         errors: errors
       )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div data-testid="page-title" class="mb-8">
        <h1 class="text-3xl font-bold">Debt Qualifier</h1>
        <p class="text-base-content/60 mt-1">Find out if you qualify for our debt relief program.</p>
      </div>

      <div :if={@submitted} data-testid="success-message" class="alert alert-success mb-6">
        <span class="font-semibold">Your profile has been accepted</span>
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
                class={[
                  "input input-bordered w-full",
                  @errors[:full_name] && "input-error"
                ]}
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
                class={[
                  "input input-bordered w-full",
                  @errors[:email] && "input-error"
                ]}
              />
              <p :if={@errors[:email]} data-testid="error-email" class="text-error text-sm mt-1">
                {@errors[:email]}
              </p>
            </div>

            <div>
              <label class="label" for="debt_amount">
                <span class="label-text font-medium">Debt Amount (USD)</span>
              </label>
              <input
                id="debt_amount"
                type="number"
                name="debt_amount"
                value={@form[:debt_amount].value}
                placeholder="15000"
                min="0"
                data-testid="input-debt-amount"
                class={[
                  "input input-bordered w-full",
                  @errors[:debt_amount] && "input-error"
                ]}
              />
              <p :if={@errors[:debt_amount]} data-testid="error-debt-amount" class="text-error text-sm mt-1">
                {@errors[:debt_amount]}
              </p>
            </div>

            <div
              :if={@eligibility != nil}
              data-testid="eligibility-result"
              class={[
                "alert",
                @eligibility == :eligible && "alert-success",
                @eligibility == :not_eligible && "alert-warning"
              ]}
            >
              <span :if={@eligibility == :eligible} data-testid="eligible-message">Eligible</span>
              <span :if={@eligibility == :not_eligible} data-testid="not-eligible-message">
                Not eligible
              </span>
            </div>

            <button type="submit" data-testid="submit-button" class="btn btn-primary w-full">
              Submit Profile
            </button>
          </form>
        </div>
      </div>

      <div :if={@submitted} class="text-center mt-4">
        <a href="/qualifier" class="btn btn-ghost btn-sm">Start over</a>
      </div>
    </Layouts.app>
    """
  end

  defp validate_fields(name, email, amount) do
    %{}
    |> maybe_add_error(:full_name, String.trim(name) == "", "Full name is required")
    |> maybe_add_error(:email, !valid_email?(email), "Valid email is required")
    |> maybe_add_error(:debt_amount, !valid_amount?(amount), "Debt amount must be a positive number")
  end

  defp maybe_add_error(errors, _key, false, _msg), do: errors
  defp maybe_add_error(errors, key, true, msg), do: Map.put(errors, key, msg)

  defp valid_email?(email) do
    String.match?(String.trim(email), ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
  end

  defp valid_amount?(amount) do
    case Integer.parse(String.trim(amount)) do
      {n, ""} when n >= 0 -> true
      {n, ".0"} when n >= 0 -> true
      _ ->
        case Float.parse(String.trim(amount)) do
          {n, ""} when n >= 0 -> true
          _ -> false
        end
    end
  end

  defp maybe_check_eligibility(""), do: nil
  defp maybe_check_eligibility(amount), do: if(valid_amount?(amount), do: check_eligibility(amount), else: nil)

  defp check_eligibility(amount) do
    case Integer.parse(String.trim(amount)) do
      {n, _} when n >= 10_000 -> :eligible
      {_n, _} -> :not_eligible
      :error ->
        case Float.parse(String.trim(amount)) do
          {n, _} when n >= 10_000.0 -> :eligible
          _ -> :not_eligible
        end
    end
  end
end
