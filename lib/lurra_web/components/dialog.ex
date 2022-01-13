defmodule LurraWeb.Components.Dialog do
  use Surface.Component

  prop title, :string, required: true
  prop show, :boolean, required: true
  prop hideEvent, :event, required: true

  slot default

  def render(assigns) do
    ~F"""
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
    """
  end
end
