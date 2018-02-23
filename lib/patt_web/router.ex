defmodule PattWeb.Router do
  use PattWeb, :router

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

  scope "/", PattWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    post "/employees/search", EmployeeController, :search
    resources "/employees", EmployeeController, except: [:edit]

    get "/payroll", PayrollController, :index
    get "/payroll/:id/new", PayrollController, :new
    post "/payroll/:id/new", PayrollController, :gen_dtr
    put "/payroll/:id/new", PayrollController, :up_dtr
    delete "/payroll/:id/new", PayrollController, :reset_dtrs
    post "/payroll/:id/save", PayrollController, :gen_payslip
    post "/payroll/:id/save", PayrollController, :up_payslip
    get "/payroll/:payslip/print", PayrollController, :print

    resources "/holidays", HolidayController
  end

  # Other scopes may use custom stacks.
  # scope "/api", PattWeb do
  #   pipe_through :api
  # end
end
