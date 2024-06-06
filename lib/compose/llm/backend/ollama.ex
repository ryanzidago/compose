defmodule Compose.LLM.Backend.Ollama do
  require Logger

  def generate(%{} = body) do
    with {:ok, body} <- build_body(body),
         {:ok, response} <- request(body),
         {:ok, body} <- decode_response(response) do
      {:ok, body}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp build_body(%{} = body) do
    body =
      %{
        model: body.model,
        stream: false,
        format: "json",
        system: body.system,
        prompt: body.input
      }

    Logger.debug(body)

    Jason.encode(body)
  end

  defp request(body) do
    :post
    |> Finch.build(config()[:base_url] <> "/api/generate", headers(), body)
    |> Finch.request(Compose.Finch, default_finch_opts())
  end

  defp decode_response(response) do
    with {:ok, body} <- Jason.decode(response.body),
         {:ok, response} <- Map.fetch(body, "response"),
         {:ok, response} <- Jason.decode(response) do
      {:ok, response}
    else
      :error -> {:error, "Failed to decode response"}
      {:error, reason} -> {:error, reason}
    end
  end

  def models do
    response =
      :get
      |> Finch.build(config()[:base_url] <> "/api/tags", headers())
      |> Finch.request!(Compose.Finch, default_finch_opts())

    body = Jason.decode!(response.body)

    body
    |> Map.get("models", [])
    |> Enum.map(fn model -> model["name"] end)
    |> Enum.sort()
  end

  def default_model do
    if "llama3:latest" in models() do
      "llama3:latest"
    else
      List.first(models())
    end
  end

  def headers do
    [
      {"content-type", "application/json"},
      {"accept", "application/json"}
    ]
  end

  def default_body do
    %{
      model: config()[:model],
      stream: config()[:stream],
      format: config()[:format]
    }
  end

  def config, do: Application.get_env(:compose, Compose.LLM)[:backends][:ollama]

  def default_finch_opts do
    Application.get_env(:finch, :opts)
  end

  def name, do: :ollama
end
