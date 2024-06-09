defmodule Compose.CSV do
  @spec to_file(list(), binary()) :: :ok | {:error, term}
  def to_file(data, filepath) when is_list(data) and is_binary(filepath) do
    data = NimbleCSV.RFC4180.dump_to_iodata(data)
    File.write(filepath, data)
  end
end
