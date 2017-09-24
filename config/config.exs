use Mix.Config

config :validix,
  types: [
    Validix.Type.Core,
  ],
  pipeline: [
    # Validix.Stage.Convert,
    Validix.Stage.Assert,
    Validix.Stage.Allowed,
    # Validix.Stage.Regex,
    # Validix.Stage.Empty,
    # Validix.Stage.Length,
    # Validix.Stage.Postprocess,
  ]
