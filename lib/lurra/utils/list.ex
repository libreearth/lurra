defmodule Lurra.Utils.Enum do

  @doc """
  Its like a Enum.filter but returns two sets with the ays and noes
  """
  def filter_split(enum, filter_fn) do
    filter_split_(enum, filter_fn, {[], []})
  end

  defp filter_split_([], _filter_fn, sets), do: sets
  defp filter_split_([item | rest], filter_fn, {ays, noes}) do
    if filter_fn.(item) do
      filter_split_(rest, filter_fn, {[item | ays], noes})
    else
      filter_split_(rest, filter_fn, {ays, [item | noes]})
    end
  end
end
