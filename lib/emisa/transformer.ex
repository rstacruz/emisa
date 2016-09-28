defmodule Emisa.Transformer do
  @moduledoc """
  Transforms a Floki HTML tree.

      transform(html, "a[href]", fn node ->
        node
      end)
  """

  alias Floki.Selector

  def transform(html, fun) do
    transform(html, "*", fun)
  end

  def transform(html, selector_string, fun) do
    selectors = get_selectors(selector_string)

    selectors |> Enum.reduce(html, fn (selector, html) ->
      traverse(html, [], selector, fun)
    end)
  end

  def traverse(html, siblings, selector, fun)
  def traverse([], _, _, _), do: []
  def traverse({}, _, _, _), do: {}
  def traverse(string, _, _, _) when is_binary(string), do: string

  def traverse([html | siblings], _, selectors, fun) do
    html = traverse(html, siblings, selectors, fun)
    siblings = traverse(siblings, [], selectors, fun)
    [html] ++ siblings
  end

  def traverse({_, _, _} = html, siblings, selector, fun) do
    if Selector.match?(html, selector) do
      combinator = selector.combinator

      case combinator do
        nil ->
          fun.(html)
          |> update_children(&traverse(&1, siblings, selector, fun))
        _ ->
          traverse_using(html, combinator, siblings, fun)
      end
    else
      html |> update_children(&traverse(&1, siblings, selector, fun))
    end
  end

  def traverse_using({_, _, _} = html, combinator, siblings, fun) do
    selector = combinator.selector

    case combinator.match_type do
      :descendant ->
        html |> update_children(&traverse(&1, [], selector, fun))
      :child ->
        html |> update_children(&traverse_children(&1, selector, fun))
      # :sibling ->
      #   siblings = traverse_sibling(siblings, selector, fun)
      # :general_sibling ->
      #   traverse_general_sibling(siblings, selector, fun)
      other ->
        raise "Combinator of type \"#{other}\" not implemented"
    end
  end

  def traverse_siblings([], _selector, _fun), do: []
  def traverse_siblings([html | siblings], selector, fun) do

  end

  def traverse_children([], _selector, _fun), do: []
  def traverse_children([html | siblings], selector, fun) do
    if Selector.match?(html, selector) do
      combinator = selector.combinator

      case combinator do
        nil ->
          html = fun.(html)
          siblings = traverse_children(siblings, selector, fun)
          [html] ++ siblings
        _ ->
          html
          |> update_children(&traverse_using(&1, combinator, siblings, fun))
      end
    end
  end

  def update_children({tag, attrs, children}, fun) do
    {tag, attrs, fun.(children)}
  end

  @doc """
  Reimplementation of Floki.Finder.get_selectors/1
  """
  def get_selectors(string) do
    string
    |> String.split(",")
    |> Enum.map(fn(s) ->
      tokens = Floki.SelectorTokenizer.tokenize(s)
      Floki.SelectorParser.parse(tokens)
    end)
  end
end
