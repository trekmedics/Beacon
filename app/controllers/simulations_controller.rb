class SimulationsController < AdministrativeInterfaceController
  # GET /simulations/new
  def new
    @simulation = Simulation.new
  end

  # POST /simulations
  def create
    @simulation = Simulation.new(simulation_params)
    if @simulation.save
      redirect_to root_path, notice: 'Simulation was successfully created.'
    else
      render :new
    end
  end

private

  def simulation_params
    return self.params.require(:simulation).permit(:first_responder_count, :incident_count, :is_random, :seed_value)
  end
end
