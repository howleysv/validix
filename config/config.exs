use Mix.Config

config :validix,
  types: [
    Validix.Type.Core,
    Validix.Type.Json,
  ],
  pipeline: [
    # Validix.Stage.Convert,
    Validix.Stage.Assert,
    Validix.Stage.Allowed,
    Validix.Stage.Regex,
    Validix.Stage.Size,
    # Validix.Stage.Postprocess,
  ]
