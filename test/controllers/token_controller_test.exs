defmodule Nexterizer.TokenControllerTest do
  use Nexterizer.ConnCase

  import Nexterizer.Factory

  alias Nexterizer.Repo
  alias Nexterizer.GuardianToken

  setup do
    {:ok, %{user: create(:user)}}
  end

  test "GET /tokens without permission", %{ user: user } do
    conn = guardian_login(user)
      |> get("/tokens")

    assert html_response(conn, 302)
  end

  test "GET /tokens with permission", %{ user: user } do
    conn = guardian_login(user, :token, perms: %{default: [:read_token]})
      |> get("/tokens")

    assert html_response(conn, 200)
  end

  test "DELETE /tokens/:jti with no login should fail" do
    token = create(:guardian_token)
    conn = conn()
    conn = delete conn, token_path(conn, :delete, token.jti)

    assert html_response(conn, 302)
    assert Repo.get(GuardianToken, token.jti).jti == token.jti
  end

  test "DELETE /tokens/:jti without revoke permission should fail", %{user: user} do
    token = create(:guardian_token)
    conn = guardian_login(user, :token)
      |> delete(token_path(conn, :delete, token.jti))

    assert html_response(conn, 302)

    new_token = Repo.get(GuardianToken, token.jti)
    refute new_token == nil
    assert new_token.jti == token.jti
  end

  test "DELETE /tokens/:jti without revoke permission should be cool", %{user: user} do
    token = create(:guardian_token)
    guardian_login(user, :token, perms: %{default: [:revoke_token]})
      |> delete(token_path(conn, :delete, token.jti))

    new_token = Repo.get(GuardianToken, token.jti)
    assert new_token == nil
  end
end
