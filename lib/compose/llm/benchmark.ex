defmodule Compose.LLM.Benchmark do
  # I want to run a single prompt in en
  # in per_form, per_section and per_field
  # and measure the time it takes to generate the responses
  # as well as how accurates the responses are
  #
  # later, I want to configure the prompt to activate examples or not
  def execute do
  end

  defp default_config do
    [
      locale: "en",
      input: %{}
    ]
  end
end
