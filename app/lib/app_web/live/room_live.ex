defmodule AppWeb.RoomLive do
  use AppWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(1)

    if connected?(socket) do
      AppWeb.Endpoint.subscribe(topic)
      AppWeb.Presence.track(self(), topic, username, %{})
    end

    {:ok,
     assign(socket,
       room_id: room_id,
       topic: topic,
       username: username,
       message: "",
       messages: [],
       user_list: [],
       temporary_assigns: [messages: []]
     )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{uuid: UUID.uuid4(), username: socket.assigns.username, content: message}
    Logger.info(message: message.content)
    AppWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    Logger.info(payload: message)
    {:noreply, assign(socket, messages: [message])}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system, uuid: UUID.uuid4(), content: "#{username} joined the chat."}
      end)

      leave_messages =
        leaves
        |> Map.keys()
        |> Enum.map(fn username ->
          %{type: :system, uuid: UUID.uuid4(), content: "#{username} left the chat."}
        end)

        Logger.info(join_messages: join_messages, leave_messages: leave_messages)

        user_list = AppWeb.Presence.list(socket.assigns.topic) |> Map.keys()

        {:noreply, assign(socket, messages: join_messages ++ leave_messages, user_list: user_list)}
  end

  def display_message(%{type: :system, uuid: uuid, content: content}) do
    ~E"<p id='<%= uuid %>'><%= content %></p>"
  end

  def display_message(%{uuid: uuid, content: content, username: username}) do
      ~E"<p id='<%= uuid %>'><b><%= username %></b>: <%= content %></p>"
  end
end
