defmodule Compose.LLM.Backend.Perplexity do
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
    |> Finch.build(config()[:base_url] <> "/chat/completions", headers(), body)
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
