defmodule Abix.Router do
  use Abix.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Abix do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api/v1", Abix do
    pipe_through :api
    get "/requests", RequestController, :index
    post "/requests", RequestController, :create
    get "/requests/:id", RequestController, :show

  end

  scope "/salemove", Abix do
    pipe_through :api
    post "/", RequestController, :salemove_callback
    post "/chat_message", RequestController, :chat_message
    post "/end_engagement", RequestController, :end_engagement
  end

  scope "/integration", Abix do
    pipe_through :api
    post "/fb", RequestController, :fb_integration
    post "/curl", RequestController, :curl_integration
    post "/twilio", RequestController, :twilio_integration
    post "/twilio/status", RequestController, :status
  end
end
