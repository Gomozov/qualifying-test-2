defmodule Extop.Scheduler do
  use GenServer

  @moduledoc """
  Calls Extop.FetchReadme and Extop.Pollster once a day. 
  """
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    Process.send(self(), :work, [])
    {:ok, state}
  end

  def handle_info(:work, state) do
    if !Application.get_env(:extop, :sql_sandbox) do
      Extop.FetchReadme.fetch()
      Extop.Pollster.polling()
    end
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 24 * 60 * 60 * 1000)
  end
end
