import Config

config :phoenix_playwrithing, PhoenixPlaywrithingWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: PhoenixPlaywrithingWeb.ErrorHTML, json: PhoenixPlaywrithingWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PhoenixPlaywrithing.PubSub,
  live_view: [signing_salt: "demoSalt1"]

config :esbuild,
  version: "0.25.4",
  phoenix_playwrithing: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "4.1.12",
  phoenix_playwrithing: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
