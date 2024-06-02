defmodule Compose.LLM.Backend.Ollama do
  require Logger

  def generate!(%{} = body) do
    body =
      default_body()
      |> Map.merge(body)
      |> Jason.encode!()

    response =
      :post
      |> Finch.build(config()[:base_url] <> "/api/generate", headers(), body)
      |> Finch.request!(Compose.Finch, default_finch_opts())

    body =
      response.body
      |> Jason.decode!()
      |> Map.get("response")
      |> Jason.decode!()

    body
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
