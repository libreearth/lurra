defmodule Lurra.TheThingsNetwork do

  def send_message(box_id, f_port, payload) do
    host = Application.get_env(:lurra, :ttn_host)
    application = Application.get_env(:lurra, :ttn_application)
    webhook = Application.get_env(:lurra, :ttn_webhook)
    url = "https://#{host}/api/v3/as/applications/#{application}/webhooks/#{webhook}/devices/#{box_id}/down/push"

    api_token = Application.get_env(:lurra, :ttn_api_token)
    headers = [
      {"Authorization",
       "Bearer #{api_token}"},
      {"Content-Type", "application/json"}
    ]

    body = %{
      "downlinks" => [
        %{
          "frm_payload" => Base.encode64(payload, padding: true),
          "f_port" => f_port
        }
      ]
    }

    case HTTPoison.post(url, Jason.encode!(body), headers) do
      {:ok, _response} -> :ok
      _ -> :error
    end
  end
end
