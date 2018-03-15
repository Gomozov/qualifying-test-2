# Extop

To install:
  * Clone repo with `git clone https://github.com/Gomozov/qualifying-test-2.git`
  * Create dev.secret.exs and test.secret.exs files with `config :extop, :github, token_header: "YOUR_GITHUB_TOKEN_HERE"`
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Your can also check working implementation here: https://shielded-shore-10557.herokuapp.com
