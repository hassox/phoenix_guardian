defmodule PhoenixGuardian.Email do
  use Bamboo.Phoenix, view: PhoenixGuardian.EmailView

  def password_reset_email(user, token) do
    base_email
    |> to(user)
    |> subject("Your Password Reset Link")
    |> render(:password_reset, user: user, token: token)
  end

  defp base_email do
    new_email
    |> from(Application.get_env(:phoenix_guardian, PhoenixGuardian.Mailer)[:from_mail])
    |> put_header("Reply-To", Application.get_env(:phoenix_guardian, PhoenixGuardian.Mailer)[:reply_to_mail])
    |> put_html_layout({PhoenixGuardian.LayoutView, "email.html"})
  end
end
