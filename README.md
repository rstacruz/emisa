# Emisa

## Installation

1. Add `emisa` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:emisa, "~> 0.1.0"}]
  end
  ```

2. Ensure `emisa` is started before your application:

  ```elixir
  def application do
    [applications: [:emisa]]
  end
  ```

## Usage

```ex
html = """
<html>
  <div>hello</div>
</html>
"""

css = """
div { color: blue }
"""

Emisa.build(html, css)
```
