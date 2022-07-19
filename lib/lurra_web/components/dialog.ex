defmodule LurraWeb.Components.Dialog do
  use Surface.LiveComponent

  prop title, :string, required: true
  prop show, :boolean, required: true
  prop hideEvent, :event, required: true

  slot default

  def render(assigns) do
    ~F"""
    <div>
    {#if @show}
      <div id="modal" class="phx-modal">
        <div class="phx-modal-content">
          <a :on-click={@hideEvent} class="phx-modal-close">&times;</a>
          <h2>{@title}</h2>
          <section>
            <#slot />
          </section>
        </div>
      </div>
    {/if}
    </div>
    """
  end

  def show(id) do
    send_update(__MODULE__, id: id, show: true)
  end

  def hide(id) do
    send_update(__MODULE__, id: id, show: false)
  end
end
