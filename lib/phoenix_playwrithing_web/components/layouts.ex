defmodule PhoenixPlaywrithingWeb.Layouts do
  use PhoenixPlaywrithingWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="navbar bg-base-200 px-4 sm:px-6 border-b border-base-300">
      <div class="flex-1">
        <a href="/" class="flex items-center gap-2 font-semibold text-lg">
          <span class="text-primary">⚡</span>
          <span>Agent Demo App</span>
        </a>
      </div>
      <nav class="flex gap-2">
        <a href="/qualifier" class="btn btn-ghost btn-sm">Qualifier</a>
        <a href="/contact-preference" class="btn btn-ghost btn-sm">Contact</a>
        <a href="/offer" class="btn btn-ghost btn-sm">Offer</a>
      </nav>
    </header>

    <main class="px-4 py-10 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  attr :flash, :map, required: true
  attr :id, :string, default: "flash-group"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end
end
