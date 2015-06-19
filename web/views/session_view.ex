defmodule PhoenixGuardian.SessionView do
  use PhoenixGuardian.Web, :view

  def render("new.json", assigns) do
    Poison.encode!(assigns.users)
  end
end
