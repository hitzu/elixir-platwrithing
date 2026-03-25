import Config

config :phoenix_playwrithing, PhoenixPlaywrithingWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "demoSecretKeyBaseForLocalDevOnlyNotForProduction1234567890abcdef",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:phoenix_playwrithing, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:phoenix_playwrithing, ~w(--watch)]}
  ]

config :phoenix_playwrithing, PhoenixPlaywrithingWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*\.(js|css|png|jpeg|jpg|gif|svg)$"E,
      ~r"lib/phoenix_playwrithing_web/(controllers|live|components)/.*\.(ex|heex)$"E,
      ~r"lib/phoenix_playwrithing_web/router\.ex$"E
    ]
  ]

config :phoenix_playwrithing, dev_routes: true

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  debug_attributes: true,
  enable_expensive_runtime_checks: true
