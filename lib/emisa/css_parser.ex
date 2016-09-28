defmodule Emisa.CssParser do
  @doc """
  Parses a CSS string.

      [
        {"@charset", [value: "\"utf-8\""]},
        {"a", [], [{"color", "blue"}]},
        {"@media", [value: "(min-width: 780px)"], [ ... ]}
      ]
  """

  def parse(src) do

  end
end
