defmodule PhoenixGuardian.ViewHelpers do
  def active_on_current(%{request_path: path}, path), do: "active"
  def active_on_current(_, _), do: ""
end
