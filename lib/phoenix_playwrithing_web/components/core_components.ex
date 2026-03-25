defmodule PhoenixPlaywrithingWeb.CoreComponents do
  @moduledoc """
  Minimal core UI components for the demo app.
  Styled with Tailwind CSS + daisyUI.
  """
  use Phoenix.Component
  use Gettext, backend: PhoenixPlaywrithingWeb.Gettext

  alias Phoenix.LiveView.JS

  # ---------------------------------------------------------------------------
  # Flash
  # ---------------------------------------------------------------------------

  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global

  slot :inner_block

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="fixed top-4 right-4 z-50 w-80 sm:w-96"
      {@rest}
    >
      <div class={[
        "alert shadow-lg",
        @kind == :info && "alert-info",
        @kind == :error && "alert-error"
      ]}>
        <span>{msg}</span>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Icon (heroicons)
  # ---------------------------------------------------------------------------

  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={["hero-icon", @name, @class]} />
    """
  end

  # ---------------------------------------------------------------------------
  # JS helpers (show / hide)
  # ---------------------------------------------------------------------------

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 200,
      transition: {"transition-all ease-out duration-200", "opacity-0 scale-95", "opacity-100 scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition: {"transition-all ease-in duration-200", "opacity-100 scale-100", "opacity-0 scale-95"}
    )
  end
end
