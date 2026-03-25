defmodule PhoenixPlaywrithingWeb.ContractsLive do
  use PhoenixPlaywrithingWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Contracts",
       submitted: false,
       errors: %{}
     )}
  end

  @impl true
  def handle_event("validate", params, socket) do
    {:noreply, assign(socket, errors: validate_acceptance(params))}
  end

  @impl true
  def handle_event("submit", params, socket) do
    errors = validate_acceptance(params)

    if map_size(errors) == 0 do
      {:noreply, assign(socket, submitted: true, errors: %{})}
    else
      {:noreply, assign(socket, errors: errors)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div data-testid="page-title" class="mb-8">
        <h1 class="text-3xl font-bold">Service agreement</h1>
        <p class="text-base-content/60 mt-1">
          Review and accept the terms to continue with enrollment.
        </p>
      </div>

      <div :if={@submitted} data-testid="success-message" class="alert alert-success mb-6">
        <span class="font-semibold">Agreement accepted — enrollment can proceed</span>
      </div>

      <div :if={!@submitted} class="card bg-base-200 border border-base-300">
        <div class="card-body">
          <div class="prose prose-sm max-w-none mb-6 text-base-content/80">
            <p>
              By enrolling you authorize us to contact you about your debt relief options and to
              share the information you provided with our partners solely for that purpose. This is a
              demo application; no legal agreement is formed.
            </p>
          </div>

          <form phx-change="validate" phx-submit="submit" class="space-y-5">
            <div class="form-control">
              <label class="label cursor-pointer justify-start gap-3">
                <input
                  type="checkbox"
                  name="accept_terms"
                  value="true"
                  class={["checkbox checkbox-primary", @errors[:accept_terms] && "checkbox-error"]}
                  data-testid="checkbox-accept-terms"
                />
                <span class="label-text">I have read and accept these terms</span>
              </label>
              <p :if={@errors[:accept_terms]} data-testid="error-accept-terms" class="text-error text-sm mt-1">
                {@errors[:accept_terms]}
              </p>
            </div>

            <button type="submit" data-testid="submit-button" class="btn btn-primary w-full">
              Accept and continue
            </button>
          </form>
        </div>
      </div>

      <div :if={@submitted} class="text-center mt-4">
        <a href="/" class="btn btn-ghost btn-sm">Back to home</a>
      </div>
    </Layouts.app>
    """
  end

  defp validate_acceptance(params) do
    if params["accept_terms"] == "true" do
      %{}
    else
      %{accept_terms: "You must accept the terms to continue"}
    end
  end
end
