defmodule AppWeb.PageLive do
  use AppWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("generate-room", _params, socket) do
    slug = "/" <> MnemonicSlugs.generate_slug(4)
    Logger.info("New Slug Generated: #{slug}")
    {:noreply, push_redirect(socket, to: slug)}
  end
end
