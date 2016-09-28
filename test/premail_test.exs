defmodule EmisaTest do
  use ExUnit.Case
  doctest Emisa

  test "basic" do
    html = ~S(<html><div class="foo">hello</div></html>)

    css = [
      {:declaration, ".foo", [
        {:rule, {"color", "blue"}, []},
        {:rule, {"width", "300px"}, []}
      ]}
    ]

    out = Emisa.run(html, css)
    assert out ===
      "<html><div style=\"color:blue;width:300px;\" class=\"foo\">hello</div></html>"
  end

  test "child selector" do
    html = ~S(<html><div class="foo">hello</div></html>)

    css = [
      {:declaration, "html div.foo", [
        {:rule, {"color", "blue"}, []},
        {:rule, {"width", "300px"}, []}
      ]}
    ]

    out = Emisa.run(html, css)
    assert out ===
      "<html><div style=\"color:blue;width:300px;\" class=\"foo\">hello</div></html>"
  end

  test "lala" do
    html = """
    <html>
    <div class="foo" id="x">hello</div>
    <span><a>Hello</a></span>
    </html>
    """

    css = [
      {:declaration, "span a", [
        {:rule, {"display", "block"}, []}
      ]},
      {:declaration, "div", [
        {:rule, {"display", "block"}, []}
      ]},
      {:declaration, ".foo", [
        {:rule, {"color", "blue"}, []},
        {:rule, {"width", "300px"}, []}
      ]}
    ]

    out = html
    |> Emisa.run(css)

    IO.puts inspect(out)
  end
end
