defmodule Compose.LLM.Backend.OpenAI do
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
    body = %{
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
