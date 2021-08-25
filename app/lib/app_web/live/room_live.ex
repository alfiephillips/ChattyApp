defmodule AppWeb.RoomLive do
  use AppWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    AppWeb.Endpoint.subscribe(topic)

    {:ok, assign(socket, room_id: room_id, topic: topic, messages: [])}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)
    AppWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    Logger.info(payload: message)
    {:noreply, assign(socket, messages: socket.assigns.messages ++ [message])}
  end
end
