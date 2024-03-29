defmodule Nexterizer.SessionControllerTest do
  use Nexterizer.ConnCase

  import Nexterizer.Factory

  alias Nexterizer.User

  setup do
    auth = create(:user)|> User.make_admin! |> with_authorization
    {:ok, %{user: auth.user}}
  end

  test "/GET login when not logged in as admin" do
    conn = conn()
    conn = get conn, admin_login_path(conn, :new)
    assert html_response(conn, 200)
  end

  test "/GET login when logged in as a normal user", %{user: user} do
    conn = guardian_login(user)
    conn = get conn, admin_login_path(conn, :new)
    assert html_response(conn, 200)
  end

  test "/POST login when not logged in", %{user: user} do
    conn = conn()
    |> post(admin_session_path(conn, :callback, "identity"), email: user.email, password: "sekrit")

    assert html_response(conn, 302)
    assert Guardian.Plug.current_resource(conn, :admin).id == user.id
    assert Guardian.Plug.current_resource(conn) == nil
  end

  test "DELETE logout when logged in", %{user: user} do
    conn = guardian_login(user, :token, key: :admin)
      |> bypass_through(Nexterizer.Router, [:browser, :admin_browser_auth])
      |> get("/")

    refute Guardian.Plug.current_resource(conn, :admin) == nil
    assert Guardian.Plug.current_resource(conn, :admin).id == user.id

    conn = delete recycle(conn), admin_logout_path(conn, :logout)
    assert Guardian.Plug.current_resource(conn, :admin) == nil
  end
end
