defmodule FeApiWeb.PageView do
  use FeApiWeb, :view
end


defmodule FeApiWeb.StudentView do
  use FeApiWeb, :view

  def render("result.json", %{result: r}) do
    %{result: r}
  end
end
