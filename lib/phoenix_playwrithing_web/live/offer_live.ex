defmodule PhoenixPlaywrithingWeb.OfferLive do
  use PhoenixPlaywrithingWeb, :live_view

  @plans [
    %{
      id: "basic",
      label: "Basic",
      price: "$49/mo",
      features: ["Debt consolidation", "Monthly report", "Email support"]
    },
    %{
      id: "standard",
      label: "Standard",
      price: "$99/mo",
      features: ["Everything in Basic", "Negotiation service", "Phone support"]
    },
    %{
      id: "premium",
      label: "Premium",
      price: "$199/mo",
      features: ["Everything in Standard", "Dedicated advisor", "Priority support included"]
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Choose Your Offer",
       plans: @plans,
       selected_plan: nil,
       submitted: false,
       errors: %{}
     )}
  end

  @impl true
  def handle_event("select_plan", %{"plan" => plan_id}, socket) do
    {:noreply, assign(socket, selected_plan: plan_id)}
  end

  @impl true
  def handle_event("submit", _params, socket) do
    if socket.assigns.selected_plan do
      {:noreply, assign(socket, submitted: true)}
    else
      {:noreply, assign(socket, errors: %{plan: "Please select a plan to continue"})}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div data-testid="page-title" class="mb-8">
        <h1 class="text-3xl font-bold">Choose Your Offer</h1>
        <p class="text-base-content/60 mt-1">
          Select the debt relief plan that works best for you.
        </p>
      </div>

      <div :if={@submitted} data-testid="success-message" class="alert alert-success mb-6">
        <span class="font-semibold">
          You selected the {@selected_plan} plan. A specialist will contact you shortly.
        </span>
      </div>

      <div :if={!@submitted}>
        <div class="grid gap-4 sm:grid-cols-3 mb-6">
          <div
            :for={plan <- @plans}
            data-testid={"plan-card-#{plan.id}"}
            phx-click="select_plan"
            phx-value-plan={plan.id}
            class={[
              "card border-2 cursor-pointer transition-all",
              @selected_plan == plan.id && "border-primary bg-primary/5",
              @selected_plan != plan.id && "border-base-300 bg-base-200 hover:border-primary/50"
            ]}
          >
            <div class="card-body p-4">
              <h2 class="card-title text-lg">{plan.label}</h2>
              <p class="text-2xl font-bold text-primary">{plan.price}</p>
              <ul class="space-y-1 mt-2">
                <li :for={f <- plan.features} class="text-sm text-base-content/70 flex gap-1">
                  <span>✓</span>
                  <span>{f}</span>
                </li>
              </ul>
              <div
                :if={plan.id == "premium"}
                data-testid="premium-plan-selector"
                class="mt-2"
              >
                <span class="badge badge-primary badge-sm">Most Popular</span>
              </div>
            </div>
          </div>
        </div>

        <div
          :if={@selected_plan == "basic"}
          data-testid="basic-support-message"
          class="alert alert-info mb-4"
        >
          <span class="font-semibold">Email-first support</span>
          <span class="text-sm ml-1">— Track progress in the app and message us anytime.</span>
        </div>

        <div
          :if={@selected_plan == "standard"}
          data-testid="standard-support-message"
          class="alert alert-info mb-4"
        >
          <span class="font-semibold">Phone & negotiation</span>
          <span class="text-sm ml-1">— We can negotiate with creditors and take your calls during business hours.</span>
        </div>

        <%!--
          INTENTIONAL BUG (MCP / agent demo): Basic & Standard banners use the real plan ids.
          This block should use @selected_plan == "premium" to match phx-value-plan, but it
          incorrectly checks "premium-plan". Selecting Premium shows no detail banner while
          the other plans do — compare with basic-support-message / standard-support-message.
          Spec: docs/flows/offer.yaml
        --%>
        <div
          :if={@selected_plan == "premium-plan"}
          data-testid="premium-support-message"
          class="alert alert-info mb-4"
        >
          <span class="font-semibold">Priority support included</span>
          <span class="text-sm ml-1">— A dedicated advisor will reach out within 24 hours.</span>
        </div>

        <p :if={@errors[:plan]} data-testid="error-plan" class="text-error text-sm mb-4">
          {@errors[:plan]}
        </p>

        <form phx-submit="submit">
          <button type="submit" data-testid="submit-button" class="btn btn-primary w-full">
            Confirm Selection
          </button>
        </form>
      </div>

      <div :if={@submitted} class="text-center mt-4">
        <a href="/offer" class="btn btn-ghost btn-sm">Start over</a>
      </div>
    </Layouts.app>
    """
  end
end
