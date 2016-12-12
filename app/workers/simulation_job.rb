class SimulationJob
  @queue = :simulation_queue

  def self.perform(params)
    simulation = Simulation.find_by(id: params['simulation_id'])
    simulation.try(:run)
  end
end
