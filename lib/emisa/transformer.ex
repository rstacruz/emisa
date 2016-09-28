defmodule Emisa.Transformer do
  @moduledoc """
  Transforms a Floki HTML tree.

      transform(html, "a[href]", fn node ->
        node
      end)
  """

  alias Floki.Selector

  @doc """
  Transforms an HTML tree by passing all nodes to function `fun`.
  """
  def transform(html, fun) do
    transform(html, "*", fun)
  end

  @doc """
  Transforms an HTML tree by passing all nodes matching `selector_string` to
  function `fun`.
  """
  def transform(html, selector_string, fun) do
    selectors = get_selectors(selector_string)

    selectors |> Enum.reduce(html, fn (selector, html) ->
      traverse([html], selector, fun) |> Enum.at(0)
    end)
  end

  defp traverse([], _, _), do: []

  defp traverse([{_, _, _} = html | siblings], selector, fun) do
    if Selector.match?(html, selector) do
      [html | siblings]
      |> traverse_combinator(selector, fun)
    else
      html = html
      |> update_children(&traverse(&1, selector, fun))
      siblings = traverse(siblings, selector, fun)
      [html | siblings]
    end
  end

  defp traverse([node | rest], selector, fun),
    do: [node | traverse(rest, selector, fun)]

  defp traverse_combinator([{_, _, _} = html | siblings], selector, fun) do
    combinator = selector.combinator
    case combinator && combinator.match_type do
      nil ->
        html = fun.(html)
        |> update_children(&traverse(&1, selector, fun))
        siblings = traverse(siblings, selector, fun)
        [html | siblings]

      :descendant -> # Find deep descendants
        html = html
        |> update_children(&traverse(&1, combinator.selector, fun))
        siblings = traverse(siblings, selector, fun)
        [html | siblings]

      :child -> # Find direct descendants
        html = html
        |> update_children(&traverse_children(&1, combinator.selector, fun))
        siblings = traverse(siblings, selector, fun)
        [html | siblings]

      :sibling ->
        siblings = siblings
        |> traverse_siblings(combinator.selector, fun)
        |> traverse(selector, fun)
        [html | siblings]

      :general_sibling ->
        siblings = siblings
        |> traverse_general_siblings(combinator.selector, fun)
        |> traverse(selector, fun)
        [html | siblings]
    end
  end

  defp traverse_children([{_, _, _} = html | siblings], selector, fun) do
    if Selector.match?(html, selector) do
      [html | siblings]
      |> traverse_combinator(selector, fun)
    else
      siblings = traverse(siblings, selector, fun)
      [html | siblings]
    end
  end

  defp traverse_children([node | rest], selector, fun),
    do: [node | traverse_children(rest, selector, fun)]

  defp traverse_siblings([{_, _, _} = html | siblings], selector, fun) do
    if Selector.match?(html, selector) do
      [html | siblings]
      |> traverse_combinator(selector, fun)
    else
      [html | siblings]
    end
  end

  defp traverse_siblings([node | rest], selector, fun),
    do: [node | traverse_siblings(rest, selector, fun)]

  defp traverse_general_siblings([{_, _, _} = html | siblings], selector, fun) do
    if Selector.match?(html, selector) do
      [html | siblings]
      |> traverse_combinator(selector, fun)
    else
      siblings = traverse(siblings, selector, fun)
      [html | siblings]
    end
  end

  defp traverse_general_siblings([node | rest], selector, fun),
    do: [node | traverse_siblings(rest, selector, fun)]

  defp update_children({tag, attrs, children}, fun) do
    {tag, attrs, fun.(children)}
  end

  # Reimplementation of Floki.Finder.get_selectors/1
  defp get_selectors(string) do
    string
    |> String.split(",")
    |> Enum.map(fn(s) ->
      tokens = Floki.SelectorTokenizer.tokenize(s)
      Floki.SelectorParser.parse(tokens)
    end)
  end
end
