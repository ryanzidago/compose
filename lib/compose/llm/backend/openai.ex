defmodule Compose.LLM.Backend.OpenAI do
  def generate!(%{} = body) do
    body =
      default_body()
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

  def default_model do
    if "gpt-4o" in models() do
      "gpt-4o"
    else
      List.first(models())
    end
  end

  def models do
    ~w(
      gpt-4-1106-preview
      gpt-3.5-turbo-16k
      gpt-3.5-turbo-1106
      gpt-4o-2024-05-13
      gpt-4o
      gpt-4-turbo-2024-04-09
      gpt-4-turbo
      gpt-4-0125-preview
      gpt-3.5-turbo-0125
      gpt-3.5-turbo
      gpt-3.5-turbo-0301
      gpt-4-turbo-preview
      gpt-3.5-turbo-0613
      gpt-4
      gpt-4-1106-vision-preview
      gpt-3.5-turbo-16k-0613
      gpt-4-0613
    )
    |> Enum.sort()
  end

  def default_body do
    %{
      stream: config()[:stream],
      model: config()[:model],
      format: config()[:format]
    }
  end

  def config do
    Application.get_env(:compose, Compose.LLM)[:backends][:openai]
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

  def name, do: :openai
end
