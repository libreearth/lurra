defmodule LurraWeb.LurraWebhookController do
  use LurraWeb, :controller

  def webhook(conn, %{ "uplink_message" => %{"frm_payload" => payload }} = params) do
    <<7, depth_mm::integer-signed-size(2)-unit(8)>> = Base.decode64!(payload)
    IO.puts "----"
    IO.puts "Depth mm: #{depth_mm}"

    valid_attrs = %{h3id: "", payload: "#{depth_mm}", timestamp: DateTime.utc_now(), type: "water_depth_mm"}

    case Lurra.Events.create_event(valid_attrs) do
     {:ok, event} ->
      nil
     error ->
      IO.inspect error
      nil

    end

    json(conn, nil)
  end
end
