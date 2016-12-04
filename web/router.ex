defmodule Todo.Router do
  use Todo.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  scope "/", Todo do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", Todo do
    pipe_through :api
    resources "/projects", ProjectController do
      resources "/tasks", ProjectTaskController
      patch "/tasks/:id/complete", ProjectTaskController, :complete
      patch "/tasks/:id/archive", ProjectTaskController, :archive
    end
    resources "/tasks", TaskController, only: [:index]
    resources "/sessions", SessionController, only: [:create]
    delete "/session", SessionController, :delete
    get "/session", SessionController, :show
  end
end
