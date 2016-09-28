defmodule Emisa.StyleRenderer do
  def style_to_s(rules)
  def style_to_s([]), do: ""
  def style_to_s([{:rule, {key, value}, []} | tail]) do
    "#{key}:#{value};" <> style_to_s(tail)
  end
end

defmodule Emisa do
  alias Emisa.Transformer
  import Emisa.StyleRenderer, only: [style_to_s: 1]

  def run(html, css, _options \\ []) do
    root = html |> Floki.parse()

    root = Enum.reduce(css, root, fn
      {:declaration, selector, rules}, root ->
        Transformer.transform(root, selector, fn node ->
          {tag, attrs, children} = node
          attrs = [{"style", style_to_s(rules)}] ++ attrs
          {tag, attrs, children}
        end)
      _, root ->
        root
    end)

    root = Transformer.transform(root, fn node ->
      node
    end)

    root
    |> Floki.raw_html()
  end
end

# TODO: Sibling (+)
# TODO: General sibling (~)
# TODO: Specificity
# TODO: Overriding existing style
