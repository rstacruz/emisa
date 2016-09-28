# Premail

## Installation

1. Add `premail` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:premail, "~> 0.1.0"}]
  end
  ```

2. Ensure `premail` is started before your application:

  ```elixir
  def application do
    [applications: [:premail]]
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

Premail.build(html, css)
```
