defmodule MetaProgramming.Github do
  @username "honungsburk"
  {:ok, _} = Application.ensure_all_started(:req)

  Req.get!("https://api.github.com/users/#{@username}/repos").body
  |> Enum.each(fn repo ->
    def unquote(
          String.to_atom(
            String.downcase(String.first(repo["name"])) <> String.slice(repo["name"], 1..-1//1)
          )
        )() do
      unquote(Macro.escape(repo))
    end
  end)

  def go(repo) do
    url = apply(__MODULE__, repo, [])["html_url"]
    IO.puts("Launching browser to #{url}...")
    System.cmd("open", [url])
  end
end
