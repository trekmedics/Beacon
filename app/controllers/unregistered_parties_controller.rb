class UnregisteredPartiesController < AdministrativeInterfaceController

  # GET /unregistered_parties
  def index
    @unregistered_parties = UnregisteredParty.all
  end

end
