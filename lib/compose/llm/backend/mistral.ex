defmodule Compose.LLM.Backend.Mistral do
  def generate(%{} = body) do
    with {:ok, body} <- build_body(body),
         {:ok, response} <- request(body),
         {:ok, body} <- decode_response(response) do
      {:ok, body}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp build_body(body) do
    body =
      %{
        model: body.model,
        stream: false,
        response_format: %{"type" => "json_object"},
        messages: [
          %{
            role: "system",
            content: body.system
          },
          %{
            role: "user",
            content: body.input
          }
        ]
      }

    Jason.encode(body)
  end

  defp request(body) do
    :post
    |> Finch.build(config()[:base_url] <> "/v1/chat/completions", headers(), body)
    |> Finch.request(Compose.Finch, default_finch_opts())
  end

  defp decode_response(response) do
    with {:ok, body} <- Jason.decode(response.body),
         {:ok, [choice | _]} <- Map.fetch(body, "choices"),
         {:ok, message} <- Map.fetch(choice, "message"),
         {:ok, content} <- Map.fetch(message, "content"),
         {:ok, content} <- Jason.decode(content) do
      {:ok, content}
    else
      :error -> {:error, "Failed to decode response"}
      {:error, reason} -> {:error, reason}
    end
  end

  def models do
    response =
      :get
      |> Finch.build(config()[:base_url] <> "/v1/models", headers())
      |> Finch.request!(Compose.Finch, default_finch_opts())

    response.body
    |> Jason.decode!()
    |> Map.get("data", [])
    |> Enum.map(& &1["id"])
    |> Enum.sort()
  end

  def default_model do
    if "mistral-small-latest" in models() do
      "mistral-small-latest"
    else
      List.first(models())
    end
  end

  def config do
    Application.get_env(:compose, Compose.LLM)[:backends][:mistral]
  end

  def default_finch_opts do
    Application.get_env(:finch, :opts)
  end

  def headers do
    [
      {"content-type", "application/json"},
      {"accept", "application/json"},
      {"authorization", "Bearer #{config()[:api_key]}"}
    ]
  end

  def name, do: :mistral
end
