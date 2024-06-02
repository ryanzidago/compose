defmodule Compose.LLM.Backend.Perplexity do
  def generate!(%{} = body) do
    body =
      default_body()
      |> Map.merge(body)
      |> Map.merge(%{
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
      })
      |> Jason.encode!()

    response =
      :post
      |> Finch.build(config()[:base_url] <> "/chat/completions", headers(), body)
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

  def default_body do
    %{
      stream: config()[:stream],
      model: config()[:model]
    }
  end

  def models do
    ~w(
    lama-3-sonar-small-32k-chat
    llama-3-sonar-small-32k-online
    llama-3-sonar-large-32k-chat
    llama-3-sonar-large-32k-online
    llama-3-8b-instruct
    llama-3-70b-instruct
    mixtral-8x7b-instruct
    )
    |> Enum.sort()
  end

  def default_model do
    if "mixtral-8x7b-instruct" in models() do
      "mixtral-8x7b-instruct"
    else
      List.first(models())
    end
  end

  def config do
    Application.get_env(:compose, Compose.LLM)[:backends][:perplexity]
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

  def name, do: :perplexity
end
