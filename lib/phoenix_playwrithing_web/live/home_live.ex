defmodule PhoenixPlaywrithingWeb.HomeLive do
  use PhoenixPlaywrithingWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Demo Home")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div data-testid="page-title" class="mb-10 text-center">
        <h1 class="text-4xl font-bold mb-2">Agent + MCP + Playwright</h1>
        <p class="text-base-content/60 text-lg">Demo App — pick a flow to explore</p>
      </div>

      <div class="grid gap-6 sm:grid-cols-2 xl:grid-cols-4">
        <.flow_card
          href="/qualifier"
          title="Qualifier"
          subtitle="Checks debt eligibility and submits a profile"
          badge="Has YAML spec + E2E test"
          badge_class="badge-success"
          data_testid="card-qualifier"
        />
        <.flow_card
          href="/contact-preference"
          title="Contact Preference"
          subtitle="Collects contact channel and preferred time"
          badge="No test yet — agent explores"
          badge_class="badge-warning"
          data_testid="card-contact-preference"
        />
        <.flow_card
          href="/offer"
          title="Offer"
          subtitle="Select a debt relief plan — one plan has a bug"
          badge="Bug seeded for demo"
          badge_class="badge-error"
          data_testid="card-offer"
        />
        <.flow_card
          href="/contracts"
          title="Contracts"
          subtitle="Review and accept the service agreement"
          badge="Enrollment step"
          badge_class="badge-info"
          data_testid="card-contracts"
        />
      </div>
    </Layouts.app>
    """
  end

  attr :href, :string, required: true
  attr :title, :string, required: true
  attr :subtitle, :string, required: true
  attr :badge, :string, required: true
  attr :badge_class, :string, default: "badge-neutral"
  attr :data_testid, :string, required: true

  defp flow_card(assigns) do
    ~H"""
    <a
      href={@href}
      data-testid={@data_testid}
      class="card bg-base-200 border border-base-300 hover:border-primary hover:shadow-lg transition-all cursor-pointer"
    >
      <div class="card-body gap-3">
        <h2 class="card-title text-xl">{@title}</h2>
        <p class="text-base-content/70 text-sm">{@subtitle}</p>
        <div class="card-actions mt-2">
          <span class={["badge badge-sm", @badge_class]}>{@badge}</span>
        </div>
      </div>
    </a>
    """
  end
end
