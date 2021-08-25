defmodule AppWeb.RoomLive do
  use AppWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    {:ok, socket}
  end
end
