defmodule Emisa do
  alias Floki.Selector

  def run(html, css, options \\ []) do
    root = html
    |> Floki.parse()

    root = Enum.reduce(css, root, fn ({selector, _, _} = declaration, root) ->
      transform(root, selector, fn node ->
        {tag, attrs, children} = node
        attrs = [{"style", "color: blue"}] ++ attrs
        {tag, attrs, children}
      end)
    end)

    root
    |> Floki.raw_html()
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
    [html | siblings]
  end

  def traverse({_, _, children} = html, siblings, selector, fun) do
    if Selector.match?(html, selector) do
      combinator = selector.combinator

      case combinator do
        nil ->
          {tag, attrs, children} = html = fun.(html)
          children = traverse(children, siblings, selector, fun)
          {tag, attrs, children}
        _ ->
          nil #traverse_using(combinator, children, siblings, fun)
      end
    else
      traverse(children, siblings, selector, fun)
    end
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

  @doc """
  Runs a function `fun` on all elements in HTML.

      # tag, attrs, children
      {"html", [{"lang", "en"}], [...]}
  """
  def map_elements(html, fun) do
    html = fun.(html)

    case html do
      {element, attributes, children} ->
        children = children
        |> Enum.map(&map_elements(&1, fun))
        {element, attributes, children}
      node ->
        node
    end
  end
end
