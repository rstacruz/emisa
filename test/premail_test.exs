defmodule PremailTest do
  use ExUnit.Case
  doctest Premail

  test "the truth" do
    assert 1 + 1 == 2
    html = """
    <html>
    <div class="foo">hello</div>
    </html>
    """

    out = html
    |> Floki.parse()
    |> map(fn x -> x end)
    |> Floki.raw_html()
    IO.puts("-> html: #{inspect(out)}")
  end

  def map(html, fun) do
    html = fun.(html)

    case html do
      {element, attributes, children} ->
        children = children
        |> Enum.map(&map(&1, fun))
        {element, attributes, children}
      node ->
        node
    end
  end
end
