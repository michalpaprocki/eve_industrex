defmodule EveIndustrexWeb.Router do
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

  scope "/api", EveIndustrexWeb do
    pipe_through :api

    get "/auth/callback", Api.Auth.CallbackController, :callback

    get "/:slug", Api.NotFoundController, :not_found
  end

  scope "/", EveIndustrexWeb do
    pipe_through :browser

    live "/boot", BootLive

    live_session :default, on_mount: [EveIndustrexWeb.Readiness] do
      live "/", HomeLive
      live "/operations", OperationsLive
      live "/market", MarketLive
      live "/market/browser", Market.BrowserLive
      live "/market/browser/*path", Market.BrowserLive
      live "/market/lp_shop", Market.LpShopLive
      live "/market/lp_shop/:hub_id", Market.LpShopLive
      live "/market/lp_shop/:hub_id/:corp_id", Market.LpShopLive
      live "/market/lp_shop/:hub_id/:corp_id/:order_type", Market.LpShopLive
      live "/item", ItemBrowserLive
      live "/item/:type_id", ItemBrowserLive
      live "/industry", IndustryLive
      live "/industry/reactions", Industry.ReactionsLive
      live "/industry/reactions/:hub_id", Industry.ReactionsLive
      live "/industry/reactions/:hub_id/:order_type", Industry.ReactionsLive
      # live "/tools/alchemy", AlchemyLive
      # live "/tools/appraise", Tools.AppraiseLive
      # live "/industry/production", Tools.ProductionLive
      live "/nook/telemetry", Dashboard.DashboardLive
    end

    get "/*slug", NotFoundController, :not_found
  end
end
