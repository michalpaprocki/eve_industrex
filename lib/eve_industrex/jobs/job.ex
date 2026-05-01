defmodule EveIndustrex.Jobs.Job do

  @type status :: :queued | :running | :done

  @type t :: %__MODULE__{
    id: binary(),
    worker: atom(),
    args: any(),
    retries: non_neg_integer(),
    max_retries: non_neg_integer()
  }

  @enforce_keys [:id, :worker]

  defstruct [
    :id,
    :worker,
    :args,
    retries: 0,
    max_retries: 3
  ]
end
