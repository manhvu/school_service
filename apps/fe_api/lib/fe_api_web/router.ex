defmodule FeApiWeb.Router do
  use FeApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {FeApiWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug FeApiWeb.Auth
  end

  # public api for front end
  scope "/api", FeApiWeb do
    pipe_through [:api, :authenticate_api_user]

    resources "/student", StudentController, only: [:create, :index]
  end
end
