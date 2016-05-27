defmodule Nexterizer.PageController do
  use Nexterizer.Web, :controller
  alias Nexterizer.Repo

  def index(conn, _params, current_user, _claims) do
    render conn, "index.html", current_user: current_user
  end
end
