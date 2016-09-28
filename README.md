# Emisa

> Email inliner via style attributes

Emisa inlines CSS styles into style attributes. This is a work in progress.

<!--
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
-->

## Usage

```ex
html = """
<html>
  <style>div { color: blue }</style>
  <div>hello</div>
</html>
"""

Emisa.run(html)
#=> "<html><div style="color:blue;">hello</div></html>"
```
