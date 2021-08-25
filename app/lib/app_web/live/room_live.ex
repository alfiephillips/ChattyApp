defmodule AppWeb.RoomLive do
  use AppWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    AppWeb.Endpoint.subscribe(topic)

    {:ok, assign(socket, room_id: room_id, topic: topic, messages: ["Hello", "How are things?"])}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)
    {:noreply, socket}
  end
end
