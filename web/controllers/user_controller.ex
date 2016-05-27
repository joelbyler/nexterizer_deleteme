defmodule Nexterizer.UserController do
  use Nexterizer.Web, :controller

  alias Nexterizer.Repo
  alias Nexterizer.User
  alias Nexterizer.Authorization

  def new(conn, params, current_user, _claims) do
    render conn, "new.html", current_user: current_user
  end
end
