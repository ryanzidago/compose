defmodule Compose.LLM do
  def generate(params) do
    {backend, params} = Map.pop!(params, :backend)
    backend.generate(params)
  end

  def module(name) when is_atom(name) do
    name
    |> Atom.to_string()
    |> module()
  end

  def module("openai") do
    Compose.LLM.Backend.OpenAI
  end

  def module(name) when is_binary(name) do
    String.to_existing_atom("Elixir.Compose.LLM.Backend.#{String.capitalize(name)}")
  end
end
