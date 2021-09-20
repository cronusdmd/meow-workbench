Mix.install([
  {:meow, path: Path.expand("..", __DIR__)},
  # or in a standalone script: {:meow, "~> 0.1.0-dev", github: "jonatanklosko/meow"},
  {:nx, "~> 0.1.0-dev", github: "elixir-nx/nx", sparse: "nx", override: true},
  {:exla, "~> 0.1.0-dev", github: "elixir-nx/nx", sparse: "exla"}
])

# In "one max" problem the objective is simply to maximise
# the number of ones in a binary string.

defmodule Problem do
  import Nx.Defn

  def size, do: 100

  @defn_compiler EXLA
  defn evaluate_one_max(genomes) do
    Nx.sum(genomes, axes: [1])
  end
end

alias Meow.{Model, Pipeline}

model =
  Model.new(&Problem.evaluate_one_max/1)
  |> Model.add_pipeline(
    MeowNx.Ops.init_binary_random_uniform(100, Problem.size()),
    Pipeline.new([
      MeowNx.Ops.selection_tournament(1.0),
      MeowNx.Ops.crossover_uniform(0.5),
      MeowNx.Ops.mutation_bit_flip(0.001),
      MeowNx.Ops.metric_best_individual(),
      Meow.Ops.max_generations(100)
    ])
  )

Meow.Runner.run(model)
