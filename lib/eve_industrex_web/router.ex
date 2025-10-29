defmodule EveIndustrexWeb.Router do
alias Tools

  use EveIndustrexWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EveIndustrexWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EveIndustrexWeb do
    pipe_through :browser

    live "/", HomeLive
    live "/market", Market.MarketLive
    live "/market/*path", Market.MarketLive
    live "/tools", ToolsLive
    live "/tools/alchemy", AlchemyLive
    live "/tools/appraise", Tools.AppraiseLive
    live "/tools/lp_shop", Tools.LpShopLive
    live "/tools/lp_shop_mk2", Tools.LpShopMk2Live
    live "/tools/production", Tools.ProductionLive
    live "/tools/reactions", Tools.ReactionsLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", EveIndustrexWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:eve_industrex, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EveIndustrexWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
