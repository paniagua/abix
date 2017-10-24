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

  scope "/salemove", Abix do
    pipe_through :api

    post "/sms", ChannelController, :send_sms
    post "/chat_message", RequestController, :chat_message

    post "/facebook", ChannelController, :send_facebook_message

    post "/end_engagement", RequestController, :end_engagement
    post "/start_engagement", RequestController, :start_engagement
  end

  scope "/facebook", Abix do
    get "/webhook", FacebookController, :verify_token
    post "/webhook", FacebookController, :message_to_operator
  end

  scope "/curl", Abix do
    post "/message", CurlController, :message_to_operator
  end

  scope "/twilio", Abix do
    pipe_through :api
    post "/message", TwilioController, :message_to_operator
    post "/status", TwilioController, :status
  end
end
