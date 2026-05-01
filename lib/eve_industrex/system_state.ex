defmodule EveIndustrex.SystemState do
  use GenServer

  def init(_init_arg) do
    {:ok, %{:ready => false}}
  end
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def set_ready() do
    GenServer.cast(__MODULE__, {:ready})
  end
  def get_status() do
    GenServer.call(__MODULE__, {:get_status})
  end

  def handle_cast({:ready}, state) do
    new_state = %{state | :ready => :true}
    {:noreply, new_state}
  end
  def handle_call({:get_status}, _from, state) do
    {:reply, state.ready, state}
  end
end
