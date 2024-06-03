defmodule Compose.LLM.Backend.Mistral do
  def generate!(%{} = body) do
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
            content: body.prompt
          }
        ]
      }
      |> Jason.encode!()

    response =
      :post
      |> Finch.build(config()[:base_url] <> "/v1/chat/completions", headers(), body)
      |> Finch.request!(Compose.Finch, default_finch_opts())

    body =
      response.body
      |> Jason.decode!()
      |> Map.get("choices")
      |> List.first()
      |> get_in(~w(message content))
      |> Jason.decode!()

    body
  end

  def models do
    # ~w(
    #   open-mistral-7b
    #   open-mixtral-8x7b
    #   open-mixtral-8x22b
    #   mistral-small-latest
    #   mistral-medium-latest
    #   mistral-large-latest
    #   mistral-embed
    #   codestral-latest
    # )
    # |> Enum.sort()

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
