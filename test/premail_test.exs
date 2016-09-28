defmodule EmisaTest do
  use ExUnit.Case
  doctest Emisa

  test "the truth" do
    assert 1 + 1 == 2
    html = """
    <html>
    <div class="foo" id="x">hello</div>
    <a>Hello</a>
    </html>
    """

    css = [
      {"a", [], [{"color", "red"}]},
      {".foo", [], [{"color", "blue"}, {"width", "300px"}]}
    ]

    out = html
    |> Emisa.run(css)

    IO.puts inspect(out)
  end
end
