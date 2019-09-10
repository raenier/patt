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
    get "/employees/delete", EmployeeController, :delete_employee
    get "/employees/schedule/profiles", EmployeeController, :sched_profile
    post "/employees/schedule/profiles", EmployeeController, :add_sched
    delete "/employees/schedule/profiles/:id", EmployeeController, :delete_schedprofile
    resources "/employees", EmployeeController, except: [:edit]
    get "/employees/resigned/index", EmployeeController, :resigned_index
    post "/employees/resigned/search", EmployeeController, :resigned_search
    put "/employees/resigned/update/:id", EmployeeController, :resigned_update

    get "/payroll", PayrollController, :index
    get "/payroll/:id/new", PayrollController, :new
    post "/payroll/:id/new", PayrollController, :gen_dtr
    put "/payroll/:id/new", PayrollController, :up_dtr
    delete "/payroll/:id/new", PayrollController, :reset_dtrs
    post "/payroll/:id/save", PayrollController, :gen_payslip
    post "/payroll/:id/save", PayrollController, :up_payslip
    get "/payroll/:payslip/print", PayrollController, :print
    get "/payroll/payperiod", PayrollController, :print_index
    get "/payroll/payperiod/:id", PayrollController, :print_bulk
    get "/payroll/payperiod/:id/summary", PayrollController, :print_summary
    post "/payroll/payperiod/:id/summary", PayrollController, :print_summary
    get "/payroll/payperiod/:id/atm", PayrollController, :print_atm
    get "/payroll/report", PayrollController, :report
    get "/payroll/report", PayrollController, :thirteenth
    get "/payroll/report/:id", PayrollController, :emp_thirteenth
    post "/payroll/report/:id", PayrollController, :gen_thirteenth
    post "/payroll/report", PayrollController, :load_thirteenth
    post "/payroll/report/update/all", PayrollController, :update_thirteenth
    get "/payroll/report/print/:year", PayrollController, :print_thirteenth

    resources "/holidays", HolidayController
    post "/holidays/year/search", HolidayController, :year_search
    resources "/users", UserController
  end

  scope "/department", PattWeb do
    pipe_through :browser # Use the default browser stack

    get "/", EmployeeController, :department
    post "/create", EmployeeController, :create_dept
    delete "/:id", EmployeeController, :delete_dept
    put "/:id/update", EmployeeController, :update_dept
    post "/:id/create", EmployeeController, :create_position
    delete "/:id/position", EmployeeController, :delete_position
  end

  scope "/attendance", PattWeb do
    pipe_through :browser # Use the default browser stack

    get "/monitoring", MonitoringController, :index
    get "/monitoring/:id", MonitoringController, :monitor
    post "/monitoring/:id", MonitoringController, :get_stats
  end

  # Other scopes may use custom stacks.
  # scope "/api", PattWeb do
  #   pipe_through :api
  # end
end
